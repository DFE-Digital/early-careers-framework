# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class StillCannotFindTheirDetailsStep < ::WizardStep
      def next_step
        :abort
      end

      def previous_step
        :nino
      end
    end
  end
end
