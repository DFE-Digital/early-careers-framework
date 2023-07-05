# frozen_string_literal: true

module Api
  module V3
    module ECF
      class ParticipantsQuery
        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def participants_for_pagination
          scope = User
                    .select(:id, :created_at)
                    .joins(participant_profiles: :induction_records)
                    .joins("JOIN (#{latest_induction_records_join.to_sql}) AS latest_induction_records_join ON latest_induction_records_join.latest_id = induction_records.id")
                    .distinct
          scope = updated_since.present? ? scope.where(users: { updated_at: updated_since.. }) : scope
          params[:sort].blank? ? scope.order(:created_at) : scope
        end

        def participants_from(paginated_join)
          # add subquery to allow grouping by user, to calculate latest induction records for multiple profiles correctly
          sub_query = User
                  .select("users.*", "COALESCE(jsonb_agg(DISTINCT latest_induction_records.latest_id), '[]') AS latest_induction_records")
                  .joins(left_outer_join_teacher_profiles)
                  .joins(left_outer_join_participant_profiles)
                  .joins(left_outer_join_induction_records)
                  .joins("JOIN (#{latest_induction_records_join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
                  .joins("INNER JOIN (#{paginated_join.to_sql}) as tmp on tmp.id = users.id")
                  .group("users.id")
                  .distinct

          scope = User
            .select("users.*")
            .includes(:participant_identities, :teacher_profile, participant_profiles: [:participant_profile_states, :schedule, :teacher_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, { induction_records: [:preferred_identity, :schedule, :delivery_partner, :participant_profile, { mentor_profile: :participant_identity, induction_programme: [school_cohort: %i[school cohort]] }] }])
            .from("(#{sub_query.to_sql}) as users")
            .distinct

          params[:sort].blank? ? scope.order("participant_profiles_induction_records.created_at ASC") : scope
        end

        def participant
          participants_from(participants_for_pagination).find(params[:id])
        end

      private

        attr_accessor :lead_provider, :params

        def filter
          params[:filter] ||= {}
        end

        def latest_induction_records_join
          InductionRecord
          .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
          .joins(:participant_profile, :schedule, { induction_programme: :partnership })
          .where(
            schedule: { cohort_id: with_cohorts.map(&:id) },
            induction_programme: {
              partnerships: {
                lead_provider_id: lead_provider.id,
                challenged_at: nil,
                challenge_reason: nil,
              },
            },
          )
        end

        def with_cohorts
          return Cohort.where(start_year: filter[:cohort].split(",")) if filter[:cohort].present?

          Cohort.national_rollout_year
        end

        def updated_since
          return if filter[:updated_since].blank?

          Time.iso8601(filter[:updated_since])
        rescue ArgumentError
          begin
            Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
          rescue ArgumentError
            raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
          end
        end

        def latest_induction_record_order
          <<~SQL
            PARTITION BY induction_records.participant_profile_id ORDER BY
              CASE
                WHEN induction_records.end_date IS NULL
                  THEN 1
                ELSE 2
              END,
              induction_records.start_date DESC,
              induction_records.created_at DESC
          SQL
        end

        def left_outer_join_teacher_profiles
          "LEFT OUTER JOIN teacher_profiles ON users.id = teacher_profiles.user_id"
        end

        def left_outer_join_participant_profiles
          "LEFT OUTER JOIN participant_profiles ON participant_profiles.teacher_profile_id = teacher_profiles.id"
        end

        def left_outer_join_induction_records
          "LEFT OUTER JOIN induction_records ON participant_profiles.id = induction_records.participant_profile_id"
        end
      end
    end
  end
end
