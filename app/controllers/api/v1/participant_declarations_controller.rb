# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable
      include JSONAPI::ActsAsResourceController

      def context
        {
          lead_provider: current_user,
          raw_event: request.raw_post
        }

      end
    end
  end
end
