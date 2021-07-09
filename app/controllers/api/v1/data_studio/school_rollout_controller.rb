# frozen_string_literal: true

module Api
  module V1
    module DataStudio
      class SchoolRolloutController < Api::ApiController
        include ApiTokenAuthenticatable

        def index
          # We are building the whole JSON result in the database as a single text field
          # so we do not want Rails attempt to try and process it any further so we
          # use render :plain and specify the content-type explicitly
          render plain: json_data.rows.first, content_type: "application/vnd.api+json"
        end

      private

        def json_data
          # NOTE: This is left as a SQL query to help analysts understand it and enable them to
          # make changes without needing to understand Ruby/ActiveRecord/Arel etc.
          # Also, this will return ~25k+ rows and there is a performance/memory overhead if this
          # instantiates School and associated objects and then serializes all of them in a similar
          # fashion to the other API endpoints.
          query = <<~SQL
            SELECT json_build_object('data',array_agg(query_rows))::text FROM (
              SELECT
                schools.id AS id,
                'school_rollout' AS type,
                json_build_object(
                  'name', schools.name,
                  'urn',  schools.urn,
                  'sent_at', nomination_emails.sent_at,
                  'opened_at', nomination_emails2.opened_at,
                  'notify_status', nomination_emails.notify_status,
                  'induction_tutor_nominated', (icp.id IS NOT NULL),
                  'tutor_nominated_time', icp.created_at,
                  'induction_tutor_signed_in', (users.current_sign_in_at IS NOT NULL),
                  'induction_programme_choice', school_cohorts.induction_programme_choice,
                  'programme_chosen_time', school_cohorts.created_at,
                  'in_partnership', (partnerships.id IS NOT NULL),
                  'partnership_time', partnerships.created_at,
                  'partnership_challenge_reason', partnerships.challenge_reason,
                  'partnership_challenge_time', partnerships.challenged_at,
                  'lead_provider', lead_providers.name,
                  'delivery_partner', delivery_partners.name
                ) as attributes
              FROM schools
              LEFT OUTER JOIN nomination_emails ON schools.id = nomination_emails.school_id
              LEFT OUTER JOIN nomination_emails nomination_emails2 ON schools.id = nomination_emails2.school_id
              LEFT OUTER JOIN induction_coordinator_profiles_schools icps ON schools.id = icps.school_id
              LEFT OUTER JOIN induction_coordinator_profiles icp ON icps.induction_coordinator_profile_id = icp.id
              LEFT OUTER JOIN users ON icp.user_id = users.id
              LEFT OUTER JOIN school_cohorts ON schools.id = school_cohorts.school_id
              LEFT OUTER JOIN partnerships ON schools.id = partnerships.school_id
              LEFT OUTER JOIN lead_providers ON partnerships.lead_provider_id = lead_providers.id
              LEFT OUTER JOIN delivery_partners ON partnerships.delivery_partner_id = delivery_partners.id
              WHERE schools.school_status_code IN (1, 3)
              AND schools.school_type_code IN (1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48)
              AND schools.administrative_district_code ILIKE 'E%'
              AND (nomination_emails.id ISNULL OR nomination_emails.id IN (SELECT id FROM nomination_emails n WHERE schools.id = n.school_id ORDER BY sent_at DESC LIMIT 1))
              AND (nomination_emails2.id ISNULL OR nomination_emails2.id IN (SELECT id FROM nomination_emails n WHERE schools.id = n.school_id ORDER BY opened_at ASC LIMIT 1))
            ) query_rows
          SQL
          ActiveRecord::Base.connection.exec_query(query)
        end

        def access_scope
          ApiToken.where(private_api_access: true)
        end
      end
    end
  end
end
