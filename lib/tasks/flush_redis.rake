# frozen_string_literal: true

namespace :redis do
  desc "Reset the redis db, used on deploys in the dev and review envs"
  task flushall: :environment do
    service_config = JSON.parse(ENV["VCAP_SERVICES"])
    redis_config = service_config["redis"]
    redis_worker_config = redis_config.select { |r| r["instance_name"].include?("worker") }.first
    redis_credentials = redis_worker_config["credentials"]
    redis = Redis.new(url: redis_credentials["uri"])
    redis.flushall
  end
end
