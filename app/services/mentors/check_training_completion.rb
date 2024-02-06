# frozen_string_literal: true

module Mentors
  class CheckTrainingCompletion < BaseService
    EARLY_ROLL_OUT_COMPLETION_DATE = Date.new(2021, 4, 19)

    def call
      return unless mentor_profile.mentor?

      set_completion_values!
    end

  private

    attr_reader :mentor_profile

    def initialize(mentor_profile:)
      @mentor_profile = mentor_profile
    end

    def set_completion_values!
      completion_date, completion_reason = if ero_mentor?
                                             [EARLY_ROLL_OUT_COMPLETION_DATE, :completed_during_early_roll_out]
                                           elsif completed_declaration.present?
                                             [completed_declaration.declaration_date, :completed_declaration_received]
                                           else
                                             [nil, nil]
                                           end

      mentor_profile.complete_training!(completion_date:, completion_reason:)
    end

    def ero_mentor?
      trn = mentor_profile.teacher_profile.trn
      trn.present? && ECFIneligibleParticipant.exists?(trn:)
    end

    def completed_declaration
      @completed_declaration ||= find_valid_declaration
    end

    def find_valid_declaration
      mentor_profile
        .participant_declarations
        .for_declaration("completed")
        .where(state: %w[submitted eligible payable paid])
        .order(declaration_date: :desc)
        .first
    end
  end
end
