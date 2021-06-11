# frozen_string_literal: true

module Api
  module V1
    module DataStudio
      class SchoolRolloutController < Api::ApiController
        include ApiTokenAuthenticatable
        include Pagy::Backend

        def index
          render json: ::DataStudio::SchoolRolloutSerializer.new(paginate(school_rollout_data))
            .serializable_hash.to_json
        end

      private

        def access_scope
          ApiToken.where(private_api_access: true)
        end

        def school_rollout_data
          ::DataStudio::FetchSchoolRolloutData.call
        end

        def paginate(scope)
          _pagy, paginated_records = pagy(scope, items: per_page, page: page)

          paginated_records
        end

        def per_page
          [params.fetch(:per_page, default_per_page).to_i, max_per_page].min
        end

        def default_per_page
          250
        end

        def max_per_page
          250
        end

        def page
          params.fetch(:page, 1).to_i
        end
      end
    end
  end
end
