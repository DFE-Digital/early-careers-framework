# frozen_string_literal: true

module Api
  module V1
    module ECF
      class ParticipantsQuery
        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def induction_records
          join = InductionRecord
                   .select("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id")
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

          nested = InductionRecord
                    .select(*necessary_fields)
                    .eager_load(:schedule)
                    .left_outer_joins(
                      induction_programme: { school_cohort: %i[school cohort] },
                      participant_profile: %i[ecf_participant_eligibility ecf_participant_validation_data teacher_profile user],
                    )
                    .joins(left_outer_join_preferred_identities)
                    .joins(left_outer_join_participant_profiles)
                    .joins(left_outer_join_participant_identities)
                    .joins(left_outer_join_mentor_profiles)
                    .joins(left_outer_join_mentor_participant_identities)
                    .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")

          scope = InductionRecord
            .select(
              "query_rows.user_id",
              "json_build_object('profiles', array_agg(query_rows))::json profiles"
            )
            .from("(#{nested.to_sql}) query_rows")
            .group(
              "query_rows.user_id",
            )

          # if updated_since.present?
          #   scope.where(users: { updated_at: updated_since.. }).order("users.updated_at ASC")
          # else
          #   scope.order("query_rows.user_created_at ASC")
          # end
        end

        def induction_record
          induction_records
            .find_by!(participant_profile: { participant_identities: { user_id: params[:id] } })
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

        def necessary_fields
          induction_record_fields +
            participant_profile_fields +
            participant_identity_fields +
            user_fields +
            ecf_participant_eligibily_fields +
            school_fields +
            teacher_profile_fields +
            ecf_participant_validation_fields +
            cohort_fields
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
            "users.updated_at AS user_updated_at",
            "users.created_at AS user_created_at",
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
          %i[
            id
            induction_programme_id
            induction_status
            mentor_profile_id
            participant_profile_id
            preferred_identity_id
            schedule_id
            training_status
            updated_at
          ]
        end
      end
    end
  end
end
