# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class StillCannotFindTheirDetailsStep < ::WizardStep
        def before_render
          wizard.set_return_point(:still_cannot_find_their_details)
        end

        def next_step
          :abort
        end
      end
    end
  end
end
