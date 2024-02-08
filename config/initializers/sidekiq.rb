# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

if ENV.key?("REDIS_URI")
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch("REDIS_URI") }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URI") }
  end
end

if ENV.key?("REDIS_URL")
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch("REDIS_URL") }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URL") }
  end
end

# Sidekiq Cron
if Sidekiq.server?
  Rails.application.config.after_initialize do
    Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(Rails.root.join("config/sidekiq_cron_schedule.yml")))
  end
end
