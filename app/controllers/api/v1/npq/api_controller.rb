# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class ApiController < ::Api::ApiController
        include ApiTokenAuthenticatable

      private

        def supported_api_token_class
          NPQRegistrationApiToken
        end
      end
    end
  end
end
