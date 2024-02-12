# frozen_string_literal: true

module ParticipantDeclarations
  class HandleMentorCompletion < BaseService
    def call
      Mentors::CheckTrainingCompletion.call(mentor_profile: participant_profile) if mentor_completion_event?
    end

  private

    attr_reader :participant_declaration, :participant_profile

    def initialize(participant_declaration:)
      @participant_declaration = participant_declaration
      @participant_profile = participant_declaration.participant_profile
    end

    def mentor_completion_event?
      participant_profile.mentor? && participant_declaration.declaration_type == "completed"
    end
  end
end
