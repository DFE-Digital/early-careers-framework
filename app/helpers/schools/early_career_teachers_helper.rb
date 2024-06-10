# frozen_string_literal: true

module Schools
  module EarlyCareerTeachersHelper
    def completed_participants(participants)
      participants.sort_by { |participant| participant.induction_completion_date || Date.new(2000, 1, 1) }
                  .reverse
    end
  end
end
