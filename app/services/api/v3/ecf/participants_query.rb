# frozen_string_literal: true

module Api
  module V3
    module ECF
      class ParticipantsQuery
        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def participants
          join = InductionRecord
                   .select("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id, induction_records.training_status")
                   .joins(:participant_profile, :schedule, { induction_programme: :partnership })
                   .where(
                     schedule: { cohort_id: with_cohorts.map(&:id) },
                     induction_programme: {
                       partnerships: {
                         lead_provider_id: lead_provider.id,
                         challenged_at: nil,
                         challenge_reason: nil,
                         pending: false,
                       },
                     },
                   )

          scope = User
                    .select(*necessary_fields)
                    .includes(:participant_identities, :teacher_profile, participant_profiles: [:participant_profile_states, :schedule, :teacher_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, { induction_records: [:preferred_identity, :schedule, :delivery_partner, { induction_programme: { partnership: [lead_provider: :cpd_lead_provider], school_cohort: %i[school cohort] } }, { mentor_profile: :participant_identity }] }])
                    .eager_load(participant_profiles: [:induction_records])
                    .joins(left_outer_join_preferred_identities)
                    .joins(left_outer_join_participant_profiles)
                    .joins(left_outer_join_participant_identities)
                    .joins(left_outer_join_mentor_profiles)
                    .joins(left_outer_join_mentor_participant_identities)
                    .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
                    .joins(left_outer_join_participant_profile_states)
                    .distinct

          if updated_since.present?
            scope.where(users: { updated_at: updated_since.. }).order("users.updated_at ASC")
          else
            scope.order("users.created_at ASC")
          end
        end

        def participant
          participants.find(params[:id])
        end

      private

        attr_accessor :lead_provider, :params

        def filter
          params[:filter] ||= {}
        end

        def with_cohorts
          return Cohort.where(start_year: filter[:cohort].split(",")) if filter[:cohort].present?

          Cohort.where("start_year > 2020")
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

        def left_outer_join_preferred_identities
          "LEFT OUTER JOIN participant_identities preferred_identities ON preferred_identities.id = induction_records.preferred_identity_id"
        end

        def left_outer_join_participant_profiles
          "LEFT OUTER JOIN participant_profiles ON participant_profiles.id = induction_records.participant_profile_id"
        end

        def left_outer_join_participant_identities
          "LEFT OUTER JOIN participant_identities ON participant_identities.id = participant_profiles.participant_identity_id"
        end

        def left_outer_join_mentor_profiles
          "LEFT OUTER JOIN participant_profiles mentor_profiles ON mentor_profiles.id = induction_records.mentor_profile_id"
        end

        def left_outer_join_mentor_participant_identities
          "LEFT OUTER JOIN participant_identities participant_identities_mentor_profiles ON participant_identities_mentor_profiles.id = mentor_profiles.participant_identity_id"
        end

        def left_outer_join_participant_profile_states
          "LEFT OUTER JOIN participant_profile_states pps on participant_profiles.id = pps.participant_profile_id AND pps.id = (
            SELECT id from participant_profile_states _pps WHERE _pps.participant_profile_id = participant_profiles.id AND _pps.state = latest_induction_records.training_status ORDER BY created_at desc LIMIT 1
          )"
        end

        def necessary_fields
          user_fields +
            participant_profile_fields +
            participant_identity_fields +
            induction_record_fields +
            ecf_participant_eligibily_fields +
            school_fields +
            teacher_profile_fields +
            ecf_participant_validation_fields +
            cohort_fields +
            participant_profile_state_fields
        end

        def school_fields
          ["schools.urn AS schools_urn"]
        end

        def teacher_profile_fields
          ["teacher_profiles.trn AS teacher_profile_trn"]
        end

        def ecf_participant_validation_fields
          ["ecf_participant_validation_data.trn AS ecf_participant_validation_data_trn"]
        end

        def cohort_fields
          ["cohorts.start_year AS start_year"]
        end

        def ecf_participant_eligibily_fields
          [
            "ecf_participant_eligibilities.reason AS ecf_participant_eligibility_reason",
            "ecf_participant_eligibilities.status AS ecf_participant_eligibility_status",
          ]
        end

        def user_fields
          [
            "users.full_name AS full_name",
            "users.email AS user_email",
            "users.created_at as user_created_at",
            "users.updated_at AS user_updated_at",
          ]
        end

        def participant_identity_fields
          [
            "participant_identities.user_id as user_id",
            "participant_identities.updated_at AS participant_identity_updated_at",
            "preferred_identities.email AS preferred_identity_email",
            "participant_identities_mentor_profiles.user_id AS mentor_user_id",
          ]
        end

        def participant_profile_fields
          [
            "participant_profiles.sparsity_uplift AS sparsity_uplift",
            "participant_profiles.pupil_premium_uplift AS pupil_premium_uplift",
            "participant_profiles.id AS participant_profile_id",
            "participant_profiles.updated_at AS participant_profile_updated_at",
            "participant_profiles.type AS participant_profile_type",
          ]
        end

        def induction_record_fields
          [
            "induction_records.induction_programme_id",
            "induction_records.induction_status",
            "induction_records.mentor_profile_id",
            "induction_records.participant_profile_id",
            "induction_records.preferred_identity_id",
            "induction_records.schedule_id",
            "induction_records.training_status",
            "induction_records.updated_at",
          ]
        end

        def participant_profile_state_fields
          [
            "participant_profile_states.state",
          ]
        end
      end
    end
  end
end
