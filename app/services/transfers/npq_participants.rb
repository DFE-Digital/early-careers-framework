# frozen_string_literal: true

module Transfers
  class NPQParticipants
    attr_reader :external_identifier, :new_npq_lead_provider_id, :course_identifier

    def initialize(external_identifier:, new_npq_lead_provider_id:, course_identifier:)
      @external_identifier = external_identifier
      @new_npq_lead_provider_id = new_npq_lead_provider_id
      @course_identifier = course_identifier
    end

    def call
      return unless npq_lead_provider && participant_identity

      transfer_participant
    end

  private

    def transfer_participant
      return unless participant_profile && npq_application

      npq_application.update!(npq_lead_provider:)
      Rails.logger.info "Participant (#{external_identifier}) was transferred to (#{npq_lead_provider.name}) successfully"
    end

    def npq_lead_provider
      @npq_lead_provider ||= NPQLeadProvider.find_by(id: new_npq_lead_provider_id)
    end

    def participant_profile
      @participant_profile ||=
        ParticipantProfile::NPQ
          .active_record
          .joins(participant_identity: { npq_applications: :npq_course })
          .find_by(participant_identity:, npq_courses: { identifier: course_identifier })
    end

    def participant_identity
      @participant_identity ||= ParticipantIdentity.find_by(external_identifier:)
    end

    def npq_application
      @npq_application ||= participant_profile.npq_application
    end
  end
end
