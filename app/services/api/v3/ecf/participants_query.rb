# frozen_string_literal: true

module Api
  module V3
    module ECF
      class ParticipantsQuery
        include Api::Concerns::FilterCohorts
        include Api::Concerns::FilterUpdatedSince
        include Api::Concerns::FilterTrainingStatus
        include Api::Concerns::FetchLatestInductionRecords
        include Concerns::Orderable

        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def participants_for_pagination
          cohort_ids = cohorts.map(&:id)

          scope = User
                    .select("users.id", "users.created_at", "users.updated_at")
                    .joins(participant_profiles: :schedule)
                    .joins(
                      ActiveRecord::Base.send(
                        :sanitize_sql_array,
                        [<<~SQL, lead_provider.id],
                          LEFT JOIN LATERAL (
                            SELECT induction_records.id AS latest_id
                            FROM induction_records
                            INNER JOIN participant_profiles
                              ON induction_records.participant_profile_id = participant_profiles.id
                            INNER JOIN teacher_profiles
                              ON participant_profiles.teacher_profile_id = teacher_profiles.id
                            INNER JOIN induction_programmes
                              ON induction_records.induction_programme_id = induction_programmes.id
                            INNER JOIN partnerships
                              ON induction_programmes.partnership_id = partnerships.id
                            WHERE partnerships.lead_provider_id = ?
                              AND partnerships.challenged_at IS NULL
                              AND partnerships.challenge_reason IS NULL
                              AND teacher_profiles.user_id = users.id
                            ORDER BY
                              CASE WHEN induction_records.end_date IS NULL THEN 1 ELSE 2 END,
                              induction_records.start_date DESC,
                              induction_records.created_at DESC
                            LIMIT 1
                          ) latest_induction_record ON true
                        SQL
                      ),
                    )
                    .joins("INNER JOIN induction_records ON induction_records.id = latest_induction_record.latest_id")
                    .joins("INNER JOIN schedules ON schedules.id = induction_records.schedule_id")
                    .left_joins(:participant_id_changes)
                    .order(sort_order(default: :created_at, model: User))
                    .distinct

          # Filters
          scope = scope.where(users: { updated_at: updated_since.. }) if updated_since_filter.present?
          scope = scope.where(induction_records: { training_status: }) if training_status.present?
          scope = scope.where(participant_id_changes: { from_participant_id: }) if from_participant_id.present?
          scope = scope.where("schedules.cohort_id IN (?)", cohort_ids) if cohort_ids.any?

          scope
        end

        def participants_from(paginated_join)
          # add subquery to allow grouping by user, to calculate latest induction records for multiple profiles correctly
          sub_query = User
                  .select("users.*", "COALESCE(jsonb_agg(DISTINCT latest_induction_records.latest_id), '[]') AS latest_induction_records")
                  .joins(left_outer_join_teacher_profiles)
                  .joins(left_outer_join_participant_profiles)
                  .joins(left_outer_join_induction_records)
                  .joins("JOIN (#{latest_induction_records_join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
                  .where(users: { id: paginated_join.map(&:id) })
                  .group("users.id")
                  .distinct

          User
            .select("users.*")
            .includes(:participant_identities, :teacher_profile, :participant_id_changes, participant_profiles: [:participant_profile_states, :schedule, :teacher_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, { induction_records: [:preferred_identity, :schedule, :delivery_partner, :participant_profile, { mentor_profile: :participant_identity, induction_programme: [school_cohort: %i[school cohort]] }] }])
            .from("(#{sub_query.to_sql}) as users")
            .order(sort_order(default: "participant_profiles_induction_records.created_at ASC", model: User))
            .distinct
        end

        def participant
          participants_from(participants_for_pagination).find(params[:id])
        end

      private

        attr_accessor :lead_provider, :params

        def from_participant_id
          filter[:from_participant_id].to_s
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
