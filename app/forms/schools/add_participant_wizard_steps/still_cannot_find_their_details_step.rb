# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class StillCannotFindTheirDetailsStep < ::WizardStep
      def before_render
        wizard.set_return_point(:still_cannot_find_their_details)
      end

      def next_step
        :abort
      end

      def previous_step
        :nino
      end
    end
  end
end
