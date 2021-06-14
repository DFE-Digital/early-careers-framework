# frozen_string_literal: true

module Api
  module V1
    module DataStudio
      class SchoolRolloutController < Api::ApiController
        include ApiTokenAuthenticatable

        def index
          render json: ::DataStudio::SchoolRolloutSerializer.new(school_rollout_data)
            .serializable_hash.to_json
        end

      private

        def access_scope
          ApiToken.where(private_api_access: true)
        end

        def school_rollout_data
          ::DataStudio::FetchSchoolRolloutData.call
        end
      end
    end
  end
end
