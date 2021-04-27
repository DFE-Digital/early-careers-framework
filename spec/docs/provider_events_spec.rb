# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Provider Events", type: :request do
  path "/provider_events" do
    post "Create provider event" do
      operationId :api_v1_create_provider_event
      tags "provider events"
      response 201, "successful" do
        let(:events) do
          {
            participants: %w[1234567890 0123456789],
          }
        end

        run_test!
      end
    end
  end
end
