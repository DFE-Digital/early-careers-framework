# frozen_string_literal: true

require "sidekiq/web"

if ENV.key?("VCAP_SERVICES")
  service_config = JSON.parse(ENV["VCAP_SERVICES"])
  redis_config = service_config["redis"]
  redis_worker_config = redis_config.select { |r| r["instance_name"].include?("worker") }.first
  redis_credentials = redis_worker_config["credentials"]

  Sidekiq.configure_server do |config|
    config.logger.level = Logger::INFO
    config.redis = {
      url: redis_credentials["uri"],
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: redis_credentials["uri"],
    }
  end
end

# Sidekiq Cron
if Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(Rails.root.join("config/sidekiq_cron_schedule.yml")))
end
