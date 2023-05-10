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
            if wizard.destination_school_cohort.blank?
              :need_training_setup
            elsif !destination_school_cohort.full_induction_programme?
              :cannot_transfer_no_fip
            else
              :none
            end
          else
            :cannot_add_mentor_at_multiple_schools
          end
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
