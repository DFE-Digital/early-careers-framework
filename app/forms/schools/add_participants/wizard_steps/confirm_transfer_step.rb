# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ConfirmTransferStep < ::WizardStep
        attr_accessor :transfer_confirmed

        validates :transfer_confirmed, inclusion: { in: %w[yes] }

        def self.permitted_params
          %i[
            transfer_confirmed
          ]
        end

        def next_step
          if wizard.need_training_setup?
            :need_training_setup
          else
            :none
          end
        end

        def journey_complete?
          next_step == :none
        end
      end
    end
  end
end
