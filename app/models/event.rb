# encoding: UTF-8
class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type          , type: Symbol
  field :title         , type: String
  field :content       , type: String
  field :author        , type: String
  field :author_avatar , type: String
  field :link          , type: String
  field :emitted_at    , type: DateTime
  field :remote_id     , type: String, default: nil

  belongs_to :source
end
