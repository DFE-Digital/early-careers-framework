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
          if wizard.sit_mentor?
            :check_answers
          elsif wizard.participant_exists?
            :transfer
          elsif wizard.found_participant_in_dqt?
            :email
          else
            :still_cannot_find_their_details
          end
        end

        def previous_step
          :cannot_find_their_details
        end
      end
    end
  end
end
