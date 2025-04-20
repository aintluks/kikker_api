Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
  config.average_scheduled_poll_interval = 15
  config.concurrency = ENV.fetch("SIDEKIQ_CONCURRENCY", 10).to_i
end
