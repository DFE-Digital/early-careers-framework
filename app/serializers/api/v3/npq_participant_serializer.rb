# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    class NPQParticipantSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def withdrawal(profile:, cpd_lead_provider:)
          if profile.withdrawn_for?(cpd_lead_provider:)
            # We are doing this in memory to avoid running those as queries on each request
            latest_participant_profile_state = profile
              .participant_profile_states.sort_by(&:created_at)
              .reverse!
              .find { |pps| pps.state == ParticipantProfileState.states[:withdrawn] && pps.cpd_lead_provider_id == cpd_lead_provider.id }

            if latest_participant_profile_state.present?
              {
                reason: latest_participant_profile_state.reason,
                date: latest_participant_profile_state.created_at.rfc3339,
              }
            end
          end
        end

        def deferral(profile:, cpd_lead_provider:)
          if profile.deferred_for?(cpd_lead_provider:)
            # We are doing this in memory to avoid running those as queries on each request
            latest_participant_profile_state = profile
              .participant_profile_states
              .sort_by(&:created_at)
              .reverse!
              .find { |pps| pps.state == ParticipantProfileState.states[:deferred] && pps.cpd_lead_provider_id == cpd_lead_provider.id }

            if latest_participant_profile_state.present?
              {
                reason: latest_participant_profile_state.reason,
                date: latest_participant_profile_state.created_at.rfc3339,
              }
            end
          end
        end
      end

      set_id :id
      set_type :'npq-participant'

      attribute :full_name

      attribute(:teacher_reference_number) do |object|
        object.teacher_profile&.trn
      end

      attribute(:updated_at) do |object|
        object.updated_at.rfc3339
      end

      attribute(:npq_enrolments) do |object, params|
        object.npq_profiles.map { |profile|
          next unless params[:cpd_lead_provider] && profile.npq_application&.npq_lead_provider&.cpd_lead_provider == params[:cpd_lead_provider]

          {
            email: profile.participant_identity&.email.presence || object.email,
            course_identifier: profile.npq_course.identifier,
            schedule_identifier: profile.schedule.schedule_identifier,
            cohort: profile.schedule.cohort.start_year.to_s,
            npq_application_id: profile.npq_application.id,
            eligible_for_funding: profile.npq_application.eligible_for_funding,
            training_status: profile.training_status,
            school_urn: profile.school_urn,
            targeted_delivery_funding_eligibility: profile.npq_application.targeted_delivery_funding_eligibility,
            withdrawal: withdrawal(profile:, cpd_lead_provider: params[:cpd_lead_provider]),
            deferral: deferral(profile:, cpd_lead_provider: params[:cpd_lead_provider]),
            created_at: profile.created_at.rfc3339,
          }.tap do |hash|
            hash.merge!(funded_place: profile.npq_application.funded_place) if FeatureFlag.active?("npq_capping")
          end
        }.compact
      end

      attribute(:participant_id_changes) do |object|
        (object.participant_id_changes || []).map do |c|
          {
            from_participant_id: c.from_participant_id,
            to_participant_id: c.to_participant_id,
            changed_at: c.created_at.rfc3339,
          }
        end
      end
    end
  end
end
