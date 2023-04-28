# frozen_string_literal: true

module Api
  module V3
    module ECF
      class UnfundedMentorsQuery
        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def unfunded_mentors
          join = InductionRecord
                   .select("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id")
                   .joins(:participant_profile, induction_programme: :partnership)
                   .where(
                     induction_programme: {
                       partnerships: {
                         challenged_at: nil,
                         challenge_reason: nil,
                       },
                     },
                   )

          funded_mentors = InductionRecord
                   .select("induction_records.id, induction_records.mentor_profile_id")
                   .joins(join_mentor_profiles)
                   .joins(join_mentor_participant_identities)
                   .joins(join_induction_programme)
                   .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")

          unfunded_mentors = InductionRecord
                   .select("induction_records.id, induction_records.participant_profile_id, partnerships.lead_provider_id, induction_records.created_at, induction_records.updated_at, induction_records.preferred_identity_id")
                   .joins("JOIN participant_profiles ON participant_profiles.id = induction_records.participant_profile_id")
                   .joins("LEFT OUTER JOIN (#{funded_mentors.to_sql}) AS funded_mentors_induction_records ON funded_mentors_induction_records.id = induction_records.id")
                   .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
                   .joins("JOIN induction_programmes on induction_records.induction_programme_id = induction_programmes.id")
                   .joins("JOIN partnerships on partnerships.id = induction_programmes.partnership_id")
                   .where("funded_mentors_induction_records.id is null")
                   .where("participant_profiles.type = 'ParticipantProfile::Mentor'")

          scope = User
                    .select(*necessary_fields)
                    .joins("JOIN teacher_profiles ON users.id = teacher_profiles.user_id")
                    .joins("JOIN participant_identities ON participant_identities.user_id = users.id")
                    .joins("JOIN participant_profiles ON participant_profiles.participant_identity_id = participant_identities.id")
                    .joins("JOIN (#{unfunded_mentors.to_sql}) AS induction_records ON participant_profiles.id = induction_records.participant_profile_id")
                    .joins("LEFT OUTER JOIN participant_identities preferred_identities ON preferred_identities.id = induction_records.preferred_identity_id")
                    .joins("LEFT OUTER JOIN ecf_participant_validation_data on ecf_participant_validation_data.participant_profile_id = induction_records.participant_profile_id")
                    .where("induction_records.lead_provider_id <> '#{lead_provider.id}'")
                    .distinct

          scope = updated_since.present? ? scope.where(users: { updated_at: updated_since.. }) : scope
          params[:sort].blank? ? scope.order("users.updated_at DESC") : scope
        end

        def unfunded_mentor
          unfunded_mentors.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          raise Api::Errors::RecordNotFoundError, I18n.t(:nothing_could_be_found)
        end

      private

        attr_accessor :lead_provider, :params

        def filter
          params[:filter] ||= {}
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

        def join_mentor_profiles
          "JOIN participant_profiles mentor_profiles ON mentor_profiles.id = induction_records.mentor_profile_id"
        end

        def join_mentor_participant_identities
          "JOIN participant_identities participant_identities_mentor_profiles ON participant_identities_mentor_profiles.id = mentor_profiles.participant_identity_id"
        end

        def join_induction_programme
          "JOIN induction_programmes on induction_records.induction_programme_id = induction_programmes.id
          JOIN partnerships on partnerships.id = induction_programmes.partnership_id"
        end

        def necessary_fields
          induction_record_fields +
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
            "participant_identities.created_at AS participant_identity_created_at",
            "participant_identities.updated_at AS participant_identity_updated_at",
            "preferred_identities.email AS preferred_identity_email",
          ]
        end

        def participant_profile_fields
          [
            "participant_profiles.id AS participant_profile_id",
            "participant_profiles.created_at AS participant_profile_created_at",
            "participant_profiles.updated_at AS participant_profile_updated_at",
            "participant_profiles.type AS participant_profile_type",
          ]
        end

        def induction_record_fields
          [
            "induction_records.created_at",
            "induction_records.updated_at",
          ]
        end
      end
    end
  end
end
