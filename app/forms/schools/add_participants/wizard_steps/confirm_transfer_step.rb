# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ConfirmTransferStep < ::WizardStep
        attr_accessor :transfer_confirmed

        validates :transfer_confirmed, presence: true

        def self.permitted_params
          %i[
            transfer_confirmed
          ]
        end

        def next_step
          if wizard.need_training_setup?
            :need_training_setup
          else
            :email
          end
        end

        def previous_step
          :date_of_birth
        end
      end
    end
  end
end

