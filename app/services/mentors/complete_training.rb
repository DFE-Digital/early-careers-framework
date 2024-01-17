# frozen_string_literal: true

module Mentors
  class CompleteTraining < BaseService
    EARLY_ROLL_OUT_COMPLETION_DATE = Date.new(2021, 4, 19)

    def call
      set_completion! if mentor_can_complete?
    end

  private

    attr_reader :mentor_profile

    def initialize(mentor_profile:)
      @mentor_profile = mentor_profile
    end

    def set_completion!
      completion_date, completion_reason = if ero_mentor?
                                             [EARLY_ROLL_OUT_COMPLETION_DATE, :completed_during_early_roll_out]
                                           else
                                             [completed_declaration.declaration_date, :completed_declaration_received]
                                           end

      mentor_profile.complete_training!(completion_date:, completion_reason:)
    end

    def mentor_can_complete?
      return false unless mentor_profile.is_a? ParticipantProfile::Mentor
      return false if mentor_profile.mentor_completion_date.present? || mentor_profile.mentor_completion_reason.present?

      return true if ero_mentor?
      return true if completed_declaration.present?

      false
    end

    def ero_mentor?
      trn = mentor_profile.teacher_profile.trn
      trn.present? && ECFIneligibleParticipant.exists?(trn:)
    end

    def completed_declaration
      # TODO: check whether really in any state?
      @completed_declaration ||= mentor_profile.participant_declarations.where(declaration_type: "completed").order(:declaration_date).last
    end
  end
end
