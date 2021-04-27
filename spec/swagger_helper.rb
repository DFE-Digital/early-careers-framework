# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s
  config.swagger_docs = {
    "v1/api_spec.json" => {
      swagger: "2.0",
      info: {
        title: "Provider Events API",
        version: "v1",
        description: "Auto generated doc",
      },
      basePath: "/api/v1",
    },
  }

  config.swagger_format = :json
end
