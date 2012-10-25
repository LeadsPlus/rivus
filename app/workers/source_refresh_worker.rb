# encoding: UTF-8

# REFRESH ALL THE THINGS!!1!
class SourceRefreshWorker
  include Sidekiq::Worker

  def perform(sources_ids)
    Source.find(sources_ids).each(&:refresh_events)
  end
end
