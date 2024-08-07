# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotFindTheirDetailsStep < ::WizardStep
        def before_render
          wizard.set_return_point(:cannot_find_their_details)
        end

        def next_step
          :nino
        end
      end
    end
  end
end
