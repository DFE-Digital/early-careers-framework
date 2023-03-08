# frozen_string_literal: true

module Transfers
  class NPQParticipants
    attr_reader :external_identifier, :current_npq_lead_provider_id, :new_npq_lead_provider_id, :course_identifier

    def initialize(external_identifier:, current_npq_lead_provider_id:, new_npq_lead_provider_id:, course_identifier:)
      @external_identifier = external_identifier
      @current_npq_lead_provider_id = current_npq_lead_provider_id
      @new_npq_lead_provider_id = new_npq_lead_provider_id
      @course_identifier = course_identifier
    end

    def call
      return unless new_npq_lead_provider && npq_application

      transfer_participant
    end

  private

    def transfer_participant
      return unless npq_application

      npq_application.update!(npq_lead_provider: new_npq_lead_provider)
      Rails.logger.info "Participant (#{external_identifier}) was transferred to (#{new_npq_lead_provider.name}) successfully"
    end

    def new_npq_lead_provider
      @new_npq_lead_provider ||= NPQLeadProvider.find_by!(id: new_npq_lead_provider_id)
    end

    def current_npq_lead_provider
      @current_npq_lead_provider ||= NPQLeadProvider.find_by!(id: current_npq_lead_provider_id)
    end

    def participant_profile
      @participant_profile ||=
        ParticipantProfile::NPQ
          .active_record
          .joins(participant_identity: { npq_applications: :npq_course })
          .find_by!(participant_identity:, npq_courses: { identifier: course_identifier })
    end

    def participant_identity
      @participant_identity ||= ParticipantIdentityResolver
                                  .call(
                                    user_id: external_identifier,
                                    course_identifier:,
                                    cpd_lead_provider: current_npq_lead_provider.cpd_lead_provider,
                                  )
    end

    def npq_application
      @npq_application ||= participant_profile.npq_application
    end
  end
end
