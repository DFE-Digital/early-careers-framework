# frozen_string_literal: true

if ENV["VCAP_SERVICES"].present?
  Rails.application.config.x.vcap_services = JSON.parse(ENV["VCAP_SERVICES"])
end
