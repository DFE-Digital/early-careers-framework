# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

if (redis_url = ENV["REDIS_URL"] || ENV["REDIS_URI"])
  Sidekiq.configure_server do |config|
    config.logger.level = Logger::WARN
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end

# Sidekiq Cron
if Sidekiq.server?
  Rails.application.config.after_initialize do
    Sidekiq::Cron::Job.load_from_hash!(YAML.load(ERB.new(IO.read(Rails.root.join("config/sidekiq_cron_schedule_erb.yml"))).result))
  end
end
