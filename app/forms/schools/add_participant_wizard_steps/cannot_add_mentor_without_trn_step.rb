# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class CannotAddMentorWithoutTrnStep < ::WizardStep
      def next_step
        # cannot proceed from here
      end

      def previous_step
        :trn
      end
    end
  end
end
