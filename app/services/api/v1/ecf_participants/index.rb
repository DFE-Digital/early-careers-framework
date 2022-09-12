# frozen_string_literal: true

module Api
  module V1
    module ECFParticipants
      class Index
        attr_reader :cpd_lead_provider, :params

        def initialize(cpd_lead_provider:, params:)
          @cpd_lead_provider = cpd_lead_provider
          @params = params
        end

        def induction_records
          scope = InductionRecord
            .where(id: induction_record_ids_with_deduped_profiles)
            .joins(schedule: [:cohort], participant_profile: { school_cohort: [:cohort] })
            .where(schedule: { cohort: with_cohorts })
            .where(participant_profile: { school_cohorts: { cohort: with_cohorts } })
            .includes(
              :schedule,
              induction_programme: {
                school_cohort: %i[
                  cohort
                  school
                ],
              },
              mentor_profile: [
                :participant_identity,
              ],
              participant_profile: %i[
                participant_identity
                user
                ecf_participant_eligibility
                ecf_participant_validation_data
                teacher_profile
              ],
            )

          if updated_since.present?
            scope
              .where(users: { updated_at: updated_since.. })
              .order("induction_records.updated_at, users.id")
          else
            scope.order("induction_records.created_at")
          end
        end

        def induction_record
          induction_records
            .joins(participant_profile: [:participant_identity])
            .where(participant_profile: { participant_identities: { external_identifier: params[:id] } })
            .first
        end

      private

        def lead_provider
          @lead_provider ||= cpd_lead_provider.lead_provider
        end

        def filter
          params[:filter] ||= {}
        end

        def with_cohorts
          return Cohort.where(start_year: filter[:cohort]) if filter[:cohort].present?

          Cohort.where("start_year > 2020")
        end

        def updated_since
          return if filter[:updated_since].blank?

          Time.iso8601(filter[:updated_since])
        rescue ArgumentError
          Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
        end

        # inner most query
        # this query deals with the following scenario
        # given one profile with 2 induction records
        # we only want to return the latest induction record
        # we also exclude any partnerships that have been challenged
        def induction_record_ids_with_deduped_induction_records
          query = InductionRecord
            .joins(induction_programme: { partnership: %i[lead_provider cohort] })
            .joins(participant_profile: %i[user participant_identity])
            .select("DISTINCT ON (participant_profiles.id) participant_profile_id, induction_records.id")
            .where(
              induction_programme: {
                partnerships: {
                  challenged_at: nil,
                  challenge_reason: nil,
                  lead_provider:,
                  cohort: with_cohorts,
                },
              },
            )
            .order("participant_profiles.id", start_date: :desc)
            .to_sql

          ActiveRecord::Base.connection.query_values("SELECT id FROM (#{query}) AS inner_query")
        end

        # second inner most query
        # this query deals with where a user can have multiple profiles
        # the work to map one user to one profile has not been done
        # therefore we must work around and select correct profile
        def induction_record_ids_with_deduped_profiles
          query = InductionRecord
            .where(id: induction_record_ids_with_deduped_induction_records)
            .joins(participant_profile: [:participant_identity])
            .select("DISTINCT ON (participant_profiles.participant_identity_id) participant_identity_id, induction_records.training_status, participant_profiles.created_at, induction_records.id")
            .order("participant_profiles.participant_identity_id", "induction_records.training_status ASC", "participant_profiles.created_at DESC")
            .to_sql

          ActiveRecord::Base.connection.query_values("SELECT id FROM (#{query}) AS inner_query")
        end
      end
    end
  end
end
