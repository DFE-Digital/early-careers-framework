# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class TrnStep < ::WizardStep
        include WhoToAddParticipantChecks

        attr_accessor :trn

        validates :trn, presence: true, teacher_reference_number: true

        def self.permitted_params
          %i[
            trn
          ]
        end

        def next_step
          if wizard.changing_answer?
            next_step_after_participant_check
          else
            :date_of_birth
          end
        end

        def journey_complete?
          next_step == :none
        end
      end
    end
  end
end
