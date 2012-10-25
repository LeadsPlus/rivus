# encoding: UTF-8

require 'securerandom'

# The Source model stores a user's sources.  A user may add any number of
# sources Once configured, they generate Events as they are received/pulled
# from the third-party API.
#
# TODO
#   - Extract authorization code to a "SourceAuthorization" object
#   - Specialize when we get more that two sources (GithubSource,
#     TrelloSource, DropboxSource, RSSSource, ...).
#
class Source
  include Mongoid::Document
  include Mongoid::Timestamps

  # Supported source types so far...
  # XXX Ok this must be set inside a small-ish configuration file now.
  TYPES = {
    github: {
      authorizable: true,
      configurable: false
    },
    rss: {
      authorizable: false,
      configurable: true
    }
  }.freeze

  field :name       , type: String
  field :type       , type: Symbol
  field :auth_data  , type: Hash     , default: nil
  field :position   , type: Fixnum   , default: 0
  field :fetched_at , type: DateTime , default: nil

  # FIXME
  #
  #   This is completely specific to the RSS Source, and should be stored in a
  #   Hash field (like auth_data?), or better: specified in a Source subclass.
  #
  #   That is, when I get to refactor source types. ^^;
  field :url, type: String, default: nil

  belongs_to :user
  has_many   :events, dependent: :destroy

  validates :name, presence: true
  validates :type, presence: true, inclusion: {in: Source::TYPES.keys}

  state_machine :state, initial: :unconfigured do
    event :configure do
      transition [:unconfigured, :ready] => :activating
    end
    event :activate do
      transition [:unconfigured, :activating] => :ready
    end
    event :pause do
      transition :ready => :paused
    end
    event :resume do
      transition :paused => :ready
    end

    # Fetch the source when it's ready.
    after_transition any => :ready do |source, transition|
      Rails.logger.info "[]"
      source.queue_refresh_events
    end
  end

  scope :ready, where(state: 'ready')

  before_save :activate_configured_types

  class << self
    # @return [Boolean]
    def valid_type?(type)
      TYPES.keys.include?(type.to_sym)
    end

    # Queue a refresh request for each active source.  Yup, that's brutal,
    # and it's triggered every N minutes by a cron job.
    #
    # FIXME
    #   - Smarter refresh policy
    #
    def refresh_events
      Rails.logger.debug "[sources] Refresh all sources"
      SourceRefreshWorker.perform_async Source.ready.map(&:id)
    end
  end

  # Some sources need to request permissions after being created.
  #
  # @return [ nil ] No need to redirect for this source
  # @return [ String ] Redirect to this URL to authorize the source
  # @see Source#authorize_url
  def authorize_after_create?
    authorize_url! if authorizable?
  end

  # @return [Boolean] wether the source requires authorization (OAuth)
  def authorizable?
    TYPES[type] && TYPES[type][:authorizable]
  end

  def configurable?
    TYPES[type] && TYPES[type][:configurable]
  end

  # The source was configured, but the activation with a third-party API
  # seems stalled (no news for 5 minutes)...
  # @return [Boolean]
  def activation_stalled?
    activating? && updated_at + 5.minutes < Time.zone.now
  end

  # Some sources need to request permissions, using OAuth for example.  This
  # method builds the URL used to request permissions.  It also resets the
  # auth_data field used to store acquired permission tokens, so don't use it
  # unless you need to ask for new permissions.
  #
  # @return [ nil ] No need to redirect for this source
  # @return [ String ] Redirect to this URL to authorize the source
  def authorize_url!
    auth_method = "#{type}_authorize_url"
    send(auth_method) if respond_to?(auth_method)
  end

  # Configure the source's auth_data from the received params.  Since this
  # received params can be quite specific to each source type, we just call the
  # specific method for the source-type.
  #
  # FIXME
  #   - No need to do this synchronously.
  #
  # @param  [Hash]                 Configuration params (from query-string)
  # @return [TrueClass]            Source configured and activated
  # @return [NilClass, FalseClass] Something's wrong, check self.errors
  def configure_auth_data!(params)
    config_method = "configure_#{type}"
    if respond_to?(config_method)
      if new_auth_data = send(config_method, auth_data, params)
        self.auth_data = new_auth_data
        return activate! if valid?
      end
    end
  end

  # Queue a refresh for this source only
  def queue_refresh_events
    SourceRefreshWorker.perform_async [id]
  end

  # Fetch this source's (new) events.  This method is triggered by the
  # SourceRefreshWorker.
  # @see SourceRefreshWorker
  def refresh_events
    return unless ready? || too_soon_to_fetch?
    Rails.logger.debug "Refresh events for source #{ name }"

    # Call the specialized refresh-method: note that this method
    # MAY change some attributes on the instance too.
    refresh_method = "refresh_#{ type }_events"
    send(refresh_method) if respond_to?(refresh_method)

    self.fetched_at = Time.zone.now
    save
  end

  # @return [Boolean] Is it too soon to refresh this source
  def too_soon_to_fetch?
    # No default interval, or never fetched yet.
    return false if default_config[:interval].nil? || fetched_at.nil?

    fetched_at + default_config[:interval].minutes > Time.zone.now
  end

  # Github OAuth authorization URL
  # @return [String]
  def github_authorize_url
    # Build URI
    url       = "https://github.com/login/oauth/authorize?client_id=%s&scope=%s&state=%s"
    client_id = default_config[:client_id]
    scopes    = default_config[:scope]
    state     = SecureRandom.uuid

    # Update state and auth_data...
    self.auth_data = {'state' => state}
    activation_stalled? ? save : configure!

    # There you go
    url % [ client_id, scopes, state ]
  end

  # Save auth_data configuration for Github.
  #
  # @params [Hash] auth_data (typically self.auth_data)
  # @params [Hash] configuration options (query-string params)
  # @return [Hash] updated auth_data with OAuth token
  # @return [NilClass] API error: check self.errors['auth_data']
  def configure_github(auth_data, params)
    # Get token
    api_token_url = 'https://github.com/login/oauth/access_token'
    auth_config = Http
      .accept(:json)
      .post api_token_url, form: {
        client_id:      default_config[:client_id],
        client_secret:  default_config[:client_secret],
        state:          auth_data['state'],
        code:           params[:code] }
    # Save token, if any
    if auth_config['error']
      errors.add(:auth_data, auth_config['error'])
      return nil
    end
    auth_data.merge(auth_config)
  end

  # Refresh source events from Github.
  def refresh_github_events
    # Get Github's events in chronological order (oldest..newset)
    api       = Github.new(oauth_token: auth_data['access_token'])
    gh_user   = api.users.get # connected user
    gh_events = api.events.received(gh_user.login).reverse

    # Save new events
    gh_events
    .find_all { |github_event| is_new_event? github_event.id }
    .each do |gh_event|
      eventable = Presenter::GithubEvent.new(gh_event)
      Event.create eventable.to_hash.merge(source_id: id)
    end
  end

  # Refresh events from an RSS feed
  # XXX Notice the smell? How this is almost the same thing for the Github
  #     events refresh method? :)
  def refresh_rss_events
    # Fetch feed
    feed = Feedzirra::Feed.fetch_and_parse(url)

    # Save new events
    feed.entries
    .find_all { |post| is_new_event? post.entry_id }
    .each do |post|
      eventable = Presenter::RSSEvent.new(post, feed)
      Event.create eventable.to_hash.merge(source_id: id)
    end
  end

  # FIXME
  #   This method MUST be over-ridden in upcoming Source subclasses
  # @return [Boolean] Wether a type is configured
  def configured?
    url.present? # only applicable to RSS sources so far.
  end

  protected

  # XXX Don't use mongo to store these
  # @return [Boolean] Wether this remote id is new for this source
  def is_new_event?(external_id)
    ! seen_events_ids.include?(external_id)
  end

  # @return [Array<String>] List of external ids from seen events
  def seen_events_ids
    @_seen_events_ids ||= events.map(&:remote_id)
  end

  # Set state to ready for types that do not need authorization,
  # and are configured.
  #
  # FIXME
  #   I can't remember if there's a self.activate_without_saving, so
  #   I'll just update the state to 'ready' for now.
  def activate_configured_types
    return unless configurable?
    self.state = 'ready' if configured?
  end

  # Source's application configuration.
  #
  # @param [Symbol] Optional configuration key (default: self.type)
  # @return [Hash]     Requested configuration
  # @return [NilClass] The requested configuration is not set.
  def default_config(key=nil)
    key ||= type
    Gaston.sources[type]
  end
end
