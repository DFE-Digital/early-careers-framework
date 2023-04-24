# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class NinoStep < ::WizardStep
        attr_accessor :nino

        validates :nino, national_insurance_number: true

        def self.permitted_params
          %i[
            nino
          ]
        end

        def next_step
          if wizard.dqt_record?
            wizard.next_step_from_record_check
          else
            :still_cannot_find_their_details
          end
        end

        def journey_complete?
          next_step == :none
        end
      end
    end
  end
end
