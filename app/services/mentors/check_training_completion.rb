# frozen_string_literal: true

module Mentors
  class CheckTrainingCompletion < BaseService
    EARLY_ROLL_OUT_COMPLETION_DATE = Date.new(2021, 4, 19)
    # hard coded for 2024 as we don't know what is required next year as yet
    # this is the date when we will no longer accept 2021 declarations
    DECLARATION_WINDOW_CLOSE_DATE = Date.new(2024, 7, 31)

    def call
      return unless mentor_profile.mentor?
      return if marked_as_started_not_completed_after_declaration_window_closes?

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

    def marked_as_started_not_completed_after_declaration_window_closes?
      return false if Time.zone.today < DECLARATION_WINDOW_CLOSE_DATE

      # eg. set as complete via csv or manually for the rule 3 category (started but not completed)
      mentor_profile.mentor_completion_date.present? && mentor_profile.started_not_completed?
    end

    def find_valid_declaration
      mentor_profile
        .participant_declarations
        .for_declaration("completed")
        .billable_or_changeable
        .order(declaration_date: :desc)
        .first
    end
  end
end
