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
          query = <<~SQL
            SELECT
              s.id,
              s.name,
              s.urn,
              ne.sent_at,
              ne.opened_at,
              ne.notify_status,
              (icp.id IS NOT NULL) AS induction_tutor_nominated,
              icp.created_at AS tutor_nominated_time,
              (u.current_sign_in_at IS NOT NULL) AS induction_tutor_signed_in,
              sc.induction_programme_choice,
              sc.created_at AS programme_chosen_time,
              (p.id IS NOT NULL) AS in_partnership,
              p.created_at AS partnership_time,
              p.challenge_reason AS partnership_challenge_reason,
              p.challenged_at AS partnership_challenge_time,
              lp.name AS lead_provider,
              dp.name AS delivery_partner,
              cip.name AS chosen_cip,
              sc.updated_at AS cip_chosen_time 
            FROM
              schools s
              FULL OUTER JOIN nomination_emails ne ON s.id = ne.school_id
              LEFT OUTER JOIN induction_coordinator_profiles_schools icps ON s.id = icps.school_id
              LEFT OUTER JOIN induction_coordinator_profiles icp ON icps.induction_coordinator_profile_id = icp.id
              LEFT OUTER JOIN users u on icp.user_id = u.id
              LEFT OUTER JOIN school_cohorts sc on s.id = sc.school_id
              LEFT OUTER JOIN partnerships p on s.id = p.school_id
              LEFT OUTER JOIN core_induction_programmes cip on sc.core_induction_programme_id = cip.id
              LEFT OUTER JOIN lead_providers lp on p.lead_provider_id = lp.id
              LEFT OUTER JOIN delivery_partners dp on p.delivery_partner_id = dp.id 
            WHERE
              s.school_status_code IN (1, 3)
              AND s.school_type_code IN (1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48)
              AND s.administrative_district_code ILIKE 'E%'
            ORDER BY s.urn
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
