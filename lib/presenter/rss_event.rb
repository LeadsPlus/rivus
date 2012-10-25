# encoding: UTF-8

module Presenter

  # @class Presenter::GithubEvent
  # Present a Github Event as returned by the github_api gem
  RSSEvent = Struct.new(:post, :feed) do
    include ActionView::Helpers::TextHelper # truncate content

    def to_hash
      {
        title:         post.title || feed.title,
        content:       truncate_content,
        author:        post.author || feed.title || "Anonymous coward",
        author_avatar: author_avatar,
        emitted_at:    post.published,
        link:          post.url,
        remote_id:     post.entry_id,
        type:          :rss
      }
    end

    # @return [String]
    def truncate_content
      truncate(Sanitize.clean(post.content), length: excerpt_length)
    end

    # @return [String]
    def author_avatar
      'FIXME'
    end

    def excerpt_length
      512
    end
  end
end
