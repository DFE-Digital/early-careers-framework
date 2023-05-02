# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class NeedTrainingSetupStep < ::WizardStep
        def next_step
          :none
        end
      end
    end
  end
end
