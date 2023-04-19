# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class NinoStep < ::WizardStep
        include WhoToAddParticipantChecks

        attr_accessor :nino

        validates :nino, national_insurance_number: true

        def self.permitted_params
          %i[
            nino
          ]
        end

        def next_step
          step = next_step_after_participant_check
          if step == :cannot_find_their_details
            :still_cannot_find_their_details
          else
            step
          end
        end

        def journey_complete?
          next_step == :none
        end
      end
    end
  end
end
