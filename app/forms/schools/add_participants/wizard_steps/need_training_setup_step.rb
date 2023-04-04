# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class NeedTrainingSetupStep < ::WizardStep
        def next_step
          :none
        end

        def previous_step
          if wizard.ect_participant?
            :confirm_transfer
          else
            :confirm_mentor_transfer
          end
        end
      end
    end
  end
end
