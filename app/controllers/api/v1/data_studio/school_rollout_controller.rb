# frozen_string_literal: true

module Api
  module V1
    module DataStudio
      class SchoolRolloutController < Api::ApiController
        include ApiTokenAuthenticatable

        def index
          render json: school_rollout_data
        end

      private

        def school_rollout_data
          {
            data: school_query.map { |row| package_row(row) },
          }
        end

        def package_row(row)
          {
            id: row["id"],
            type: "school_rollout",
            attributes: row.except("id"),
          }
        end

        def school_query
          # NOTE: This is left as a SQL query to help analysts understand it and enable them to make changes
          # without needing to understand Ruby/ActiveRecord/Arel etc.
          # Also, this will return ~25k+ rows and there is a performance/memory overhead if this instantiates
          # School and associated objects and then serializes all of them in a similar fashion to the other API
          # endpoints.
          query = <<~SQL
            SELECT
              schools.id,
              schools.name,
              schools.urn,
              nomination_emails.sent_at,
              nomination_emails.opened_at,
              nomination_emails.notify_status,
              (icp.id IS NOT NULL) AS induction_tutor_nominated,
              icp.created_at AS tutor_nominated_time,
              (users.current_sign_in_at IS NOT NULL) AS induction_tutor_signed_in,
              school_cohorts.induction_programme_choice,
              school_cohorts.created_at AS programme_chosen_time,
              (partnerships.id IS NOT NULL) AS in_partnership,
              partnerships.created_at AS partnership_time,
              partnerships.challenge_reason AS partnership_challenge_reason,
              partnerships.challenged_at AS partnership_challenge_time,
              lead_providers.name AS lead_provider,
              delivery_partners.name AS delivery_partner,
              cip.name AS chosen_cip,
              school_cohorts.updated_at AS cip_chosen_time 
            FROM
              schools
              FULL OUTER JOIN nomination_emails ON schools.id = nomination_emails.school_id
              LEFT OUTER JOIN induction_coordinator_profiles_schools icps ON schools.id = icps.school_id
              LEFT OUTER JOIN induction_coordinator_profiles icp ON icps.induction_coordinator_profile_id = icp.id
              LEFT OUTER JOIN users ON icp.user_id = users.id
              LEFT OUTER JOIN school_cohorts ON schools.id = school_cohorts.school_id
              LEFT OUTER JOIN partnerships ON schools.id = partnerships.school_id
              LEFT OUTER JOIN core_induction_programmes cip ON school_cohorts.core_induction_programme_id = cip.id
              LEFT OUTER JOIN lead_providers ON partnerships.lead_provider_id = lead_providers.id
              LEFT OUTER JOIN delivery_partners ON partnerships.delivery_partner_id = delivery_partners.id 
            WHERE
              schools.school_status_code IN (1, 3)
              AND schools.school_type_code IN (1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48)
              AND schools.administrative_district_code ILIKE 'E%'
            ORDER BY schools.urn
          SQL
          ActiveRecord::Base.connection.select_all(query)
        end

        def access_scope
          ApiToken.where(private_api_access: true)
        end
      end
    end
  end
end
