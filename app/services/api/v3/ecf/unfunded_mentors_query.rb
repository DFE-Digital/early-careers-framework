# frozen_string_literal: true

module Api
  module V3
    module ECF
      class UnfundedMentorsQuery
        include Api::Concerns::FilterUpdatedSince
        include Api::Concerns::FetchLatestInductionRecords
        include Concerns::Orderable

        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def unfunded_mentors
          ActiveRecord::Base.connection.execute("set statement_timeout to 0")

          scope = InductionRecord.distinct
                   .select(*necessary_fields)
                   .joins("JOIN participant_profiles ON participant_profiles.id = induction_records.mentor_profile_id")
                   .joins("JOIN (#{latest_induction_records_join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
                   .joins("JOIN (#{latest_induction_records_for_mentor_join.to_sql}) AS latest_mentor_induction_records ON latest_mentor_induction_records.participant_profile_id = participant_profiles.id AND row_number = 1")
                   .joins("JOIN induction_programmes on induction_programmes.id = induction_records.induction_programme_id")
                   .joins("JOIN partnerships on partnerships.id = induction_programmes.partnership_id")
                   .joins("JOIN participant_identities ON participant_identities.id = latest_mentor_induction_records.preferred_identity_id")
                   .joins("JOIN users on users.id = participant_identities.user_id")
                   .joins("JOIN teacher_profiles ON teacher_profiles.user_id = users.id")
                   .joins("LEFT OUTER JOIN ecf_participant_validation_data on ecf_participant_validation_data.participant_profile_id = induction_records.mentor_profile_id")
                   .where(participant_profiles: { type: "ParticipantProfile::Mentor" })
                   .where("induction_records.mentor_profile_id not in (select distinct participant_profile_id from (#{latest_induction_records_join.to_sql}) AS latest_induction_records)")
                   .order(sort_order(default: "users.created_at ASC", model: User))

          scope = scope.where(users: { updated_at: updated_since.. }) if updated_since_filter.present?
          scope
        end

        def unfunded_mentor
          scope = unfunded_mentors
            .where(participant_identities: { user_id: params[:id] })

          scope.first.presence || raise(ActiveRecord::RecordNotFound)
        end

      private

        attr_accessor :lead_provider, :params

        def latest_induction_records_for_mentor_join
          InductionRecord
          .select(Arel.sql("ROW_NUMBER() OVER (#{latest_induction_record_order}) AS row_number, induction_records.participant_profile_id, induction_records.preferred_identity_id"))
          .joins(:participant_profile, { induction_programme: :partnership })
          .where.not(induction_programme: { partnerships: { lead_provider: nil } })
          .where(
            induction_programme: {
              partnerships: {
                challenged_at: nil,
                challenge_reason: nil,
              },
            },
          )
        end

        def latest_induction_records_join
          super
            .select(Arel.sql("induction_records.participant_profile_id, induction_records.mentor_profile_id"))
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
