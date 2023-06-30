# frozen_string_literal: true

module Api
  module V3
    module ECF
      class UnfundedMentorsQuery
        include Concerns::FilterUpdatedSince

        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def unfunded_mentors
          join = InductionRecord
                   .select("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id, induction_records.participant_profile_id, induction_records.mentor_profile_id")
                   .joins(:participant_profile, induction_programme: :partnership)
                   .where(
                     induction_programme: {
                       partnerships: {
                         lead_provider_id: lead_provider.id,
                         challenged_at: nil,
                         challenge_reason: nil,
                       },
                     },
                   )

          scope = InductionRecord.distinct
                   .select(*necessary_fields)
                   .joins("JOIN participant_profiles ON participant_profiles.id = induction_records.mentor_profile_id")
                   .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
                   .joins("JOIN induction_programmes on induction_programmes.id = induction_records.induction_programme_id")
                   .joins("JOIN partnerships on partnerships.id = induction_programmes.partnership_id")
                   .joins("JOIN participant_identities ON participant_identities.id = participant_profiles.participant_identity_id")
                   .joins("JOIN users on users.id = participant_identities.user_id")
                   .joins("JOIN teacher_profiles ON teacher_profiles.user_id = users.id")
                   .joins("LEFT OUTER JOIN ecf_participant_validation_data on ecf_participant_validation_data.participant_profile_id = induction_records.mentor_profile_id")
                   .where("induction_records.mentor_profile_id not in (select distinct participant_profile_id from (#{join.to_sql}) AS latest_induction_records)")

          scope = updated_since_filter.present? ? scope.where(users: { updated_at: updated_since.. }) : scope
          params[:sort].blank? ? scope.order("users.created_at ASC") : scope
        end

        def unfunded_mentor
          scope = unfunded_mentors
            .where(participant_profile: { participant_identities: { user_id: params[:id] } })
          scope = scope.where(participant_profile: { type: "ParticipantProfile::Mentor" }) if scope.size > 1

          scope.first.presence || raise(ActiveRecord::RecordNotFound)
        end

      private

        attr_accessor :lead_provider, :params

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

        def necessary_fields
          participant_profile_fields +
            participant_identity_fields +
            user_fields +
            teacher_profile_fields +
            ecf_participant_validation_fields
        end

        def teacher_profile_fields
          ["teacher_profiles.trn AS teacher_profile_trn"]
        end

        def ecf_participant_validation_fields
          ["ecf_participant_validation_data.trn AS ecf_participant_validation_data_trn"]
        end

        def user_fields
          [
            "users.full_name AS full_name",
            "users.email AS user_email",
            "users.created_at AS user_created_at",
            "users.updated_at AS user_updated_at",
          ]
        end

        def participant_identity_fields
          [
            "participant_identities.user_id as user_id",
            "participant_identities.email AS preferred_identity_email",
          ]
        end

        def participant_profile_fields
          [
            "participant_profiles.id AS participant_profile_id",
            "participant_profiles.type AS participant_profile_type",
          ]
        end
      end
    end
  end
end
