# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class CompleteStep < ::WizardStep
      def next_step
        :none
      end

      def previous_step
        :none
      end
    end
  end
end
