Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0',
                   namespace: "rivus_#{Rails.env}" }

  # Kiqstand avoids that sidekiq workers exhaust the mongodb connection pool.
  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0',
                   namespace: "rivus_#{Rails.env}",
                   size: 5 }
end
