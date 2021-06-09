# frozen_string_literal: true

module Api
  module V1
    module DataStudio
      class SchoolRolloutController < Api::ApiController
        include ApiTokenAuthenticatable
        include Pagy::Backend

        def index
          render json: ::DataStudio::SchoolRolloutSerializer.new(paginate(rollout_data))
            .serializable_hash.to_json
        end

      private

        def rollout_data
          School
            .eligible
            .joins(:nomination_emails)
            .left_joins(:induction_coordinator_profiles_schools)
            .left_joins(:induction_coordinator_profiles)
            .left_joins(induction_coordinator_profiles: :user)
            .left_joins(:school_cohorts)
            .left_joins(:partnerships)
            .select("schools.id",
                    "schools.name",
                    "schools.urn",
                    "nomination_emails.sent_at AS sent_at",
                    "nomination_emails.opened_at AS opened_at",
                    "nomination_emails.notify_status AS notify_status",
                    "(induction_coordinator_profiles.id IS NOT NULL) AS induction_tutor_nominated",
                    "induction_coordinator_profiles.created_at AS tutor_nominated_time",
                    "(users.current_sign_in_at IS NOT NULL) AS induction_tutor_signed_in",
                    "school_cohorts.induction_programme_choice",
                    "school_cohorts.created_at AS programme_chosen_time",
                    "(partnerships.id IS NOT NULL) AS in_partnership",
                    "partnerships.created_at AS partnership_time")
            .order("schools.urn ASC")
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
