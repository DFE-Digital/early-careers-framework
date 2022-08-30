# frozen_string_literal: true

module Api
  module V1
    module ECFParticipants
      class Index
        def initialize(lead_provider, params)
          self.lead_provider = lead_provider
          self.params        = params
        end

        def induction_records
          join = InductionRecord
                   .select("induction_records.id, ROW_NUMBER() OVER (PARTITION BY induction_records.participant_profile_id ORDER BY induction_records.created_at DESC) AS created_at_precedence")
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

          scope = InductionRecord
                    .references(participant_profile: %i[participant_identity])
                    .includes(
                      :preferred_identity,
                      :schedule,
                      induction_programme: { school_cohort: %i[school cohort] },
                      mentor_profile: [:participant_identity],
                      participant_profile: %i[ecf_participant_eligibility ecf_participant_validation_data participant_identity teacher_profile user],
                    )
                    .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.id = induction_records.id AND latest_induction_records.created_at_precedence = 1")

          if updated_since.present?
            scope.where(users: { updated_at: updated_since.. }).order("users.updated_at ASC")
          else
            scope.order("users.created_at ASC")
          end
        end

        def induction_record
          induction_records
            .joins(participant_profile: %i[participant_identity])
            .find_by!(participant_profile: { participant_identities: { external_identifier: params[:id] } })
        end

      private

        attr_accessor :lead_provider, :params

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
      end
    end
  end
end
