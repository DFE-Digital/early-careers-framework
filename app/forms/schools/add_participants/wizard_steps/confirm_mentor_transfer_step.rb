# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ConfirmMentorTransferStep < ::WizardStep
        attr_accessor :transfer_confirmed

        validates :transfer_confirmed, inclusion: { in: %w[yes no] }

        def self.permitted_params
          %i[
            transfer_confirmed
          ]
        end

        def next_step
          if transfer_confirmed?
            if wizard.need_training_setup?
              :need_training_setup
            else
              :none
            end
          else
            :cannot_add_mentor_at_multiple_schools
          end
        end

        def previous_step
          :date_of_birth
        end

        def journey_complete?
          next_step == :none
        end

        def transfer_confirmed?
          transfer_confirmed == "yes"
        end
      end
    end
  end
end
