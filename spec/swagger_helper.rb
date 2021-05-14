# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s
  config.swagger_docs = {
    "v1/api_spec.json" => {
      openapi: "3.0.1",
      info: {
        title: "API documentation",
        version: "v1",
        description: "API for DfE CPD's participant service",
      },
      components: {
        securitySchemes: {
          bearerAuth: {
            bearerFormat: "string",
            type: "http",
            scheme: "bearer",
          },
        },
      },
      security: [
        bearerAuth: [],
      ],
    },
  }
  config.swagger_format = :json
end
