# frozen_string_literal: true

module Api
  module V1
    class NpqProfilesController < Api::ApiController
      include ApiTokenAuthenticatable
      include JSONAPI::ActsAsResourceController

    private

      def access_scope
        ApiToken.where(private_api_access: true)
      end
    end
  end
end
