# encoding: UTF-8

module Presenter

  # @class Presenter::GithubEvent
  # Present a Github Event as returned by the github_api gem
  class GithubEvent

    @@template_base = 'events/templates/github_events/%s.haml'
    @@github_root   = 'https://github.com'

    attr_reader :event

    def initialize(event)
      @event    = event
      @template = nil
    end

    def to_hash
      {
        title:         title,
        content:       content,
        author:        author,
        author_avatar: author_avatar,
        emitted_at:    @event.created_at,
        link:          link,
        type:          :github,
        remote_id:     @event.id
      }
    end

    # Get the proper template for the received event type.
    # @return [Tilt::HamlTemplate]
    def template
      return @template unless @template.nil?
      relative_path = @@template_base % template_name
      abs_path      = Rails.root.join('app', 'views', relative_path)
      @template ||= Tilt::HamlTemplate.new(abs_path.to_s)
    end

    # Template name
    # @return [ String ]
    def template_name
      @template_name ||= @event.type.underscore
    end

    # Event's title
    # @return [String]
    def title
      case event.type
        when 'CommitCommentEvent'
          "#{ author } commented on #{ event.payload.comment.commit_id }"
        when 'CreateEvent'
          "#{ author } created #{ event.ref }"
        when 'DeleteEvent'
          "#{ author } deleted #{ event.ref }"
        when 'DownloadEvent'
          "#{ author } created a download package #{ event.payload.download.name }"
        when 'FollowEvent'
          "#{ author } followed #{ event.payload.target.login }"
        when 'ForkEvent'
          "#{ author } forked #{ event.payload.forkee.login }"
        when 'ForkApplyEvent'
          "FIXME fork apply event"
        when 'GistEvent'
          "FIXME gist event"
        when 'GollumEvent'
          pages =  event.payload.pages.map(&:name).join(',') 
          s = pages.size > 1 ? 's' : ''
          "#{ author } updated wiki page#{ s } #{ pages }"
        when 'IssueCommentEvent'
          'FIXME issue comment event'
        when 'IssuesEvent'
          'FIXME issues event'
        when 'MemberEvent'
          'FIXME member event'
        when 'PublicEvent'
          'FIXME public event'
        when 'PullRequestEvent'
          'FIXME pull request event'
        when 'PullRequestReviewCommentEvent'
          'FIXME pull request review comment event'
        when 'PushEvent'
          "#{ author } pushed to #{ event.repo.name }"
        when 'TeamAddEvent'
          'FIXME team add event'
        when 'WatchEvent'
          "#{ author } started watching #{ event.repo.name }"
      end
    end

    # @return [String]
    def content
      template.render(self, event: @event)
    end

    # @return [String]
    def author
      event.actor.login
    end

    # @return [String]
    def author_avatar
      event.actor.avatar_url
    end

    # @return [String]
    def link
      case event.type
        when 'CommitCommentEvent'
          'FIXME commit comment url'
        when 'CreateEvent'
          "FIXME create url"
        when 'DeleteEvent'
          "FIXME delete url"
        when 'DownloadEvent'
          "FIXME download url"
        when 'FollowEvent'
          event.payload.target.html_url
        when 'ForkEvent'
          event.payload.forkee.html_url
        when 'ForkApplyEvent'
          "FIXME fork apply event url"
        when 'GistEvent'
          "FIXME gist event url"
        when 'GollumEvent'
          "FIXME gollum event url url"
        when 'IssueCommentEvent'
          'FIXME issue comment event url'
        when 'IssuesEvent'
          'FIXME issues event url'
        when 'MemberEvent'
          'FIXME member event url'
        when 'PublicEvent'
          'FIXME public event url'
        when 'PullRequestEvent'
          'FIXME pull request event url'
        when 'PullRequestReviewCommentEvent'
          'FIXME pull request review comment event url'
        when 'PushEvent'
          commit_url(event.repo.name, event.payload.commits.last.sha)
        when 'TeamAddEvent'
          'FIXME team add event url'
        when 'WatchEvent'
          "#{ @@github_root }/#{ event.repo.name }"
      end
    end

    # @return [String]
    def commit_url(repo_name, sha)
      "#{ @@github_root }/#{ repo_name }/commit/#{ sha }"
    end

  end
end
