# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class NeedTrainingSetupStep < ::WizardStep
        def next_step
          :none
        end

        def previous_step
          :email
        end
      end
    end
  end
end
