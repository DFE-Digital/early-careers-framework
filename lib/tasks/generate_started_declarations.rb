# frozen_string_literal: true

class GenerateStartedDeclarations
  class << self
    def call
      raise "Do not run on production environments" if Rails.env.production? || Rails.env.sandbox?

      LeadProvider.all.each do |ecf_lead_provider|
        cpd_lead_provider = ecf_lead_provider.cpd_lead_provider
        ecf_lead_provider.ecf_participants.each do |ecf_participant|
          course_identifier = ecf_participant.early_career_teacher? ? "ecf-induction" : "ecf-mentor"
          begin
            RecordParticipantDeclaration.call(
              participant_id: ecf_participant.id,
              declaration_type: "started",
              course_identifier:,
              declaration_date: Time.zone.now.rfc3339,
              cpd_lead_provider:,
            )
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
