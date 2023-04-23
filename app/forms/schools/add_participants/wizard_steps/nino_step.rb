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
            if wizard.sit_mentor?
              wizard.dqt_record_has_different_name? ? :known_by_another_name : :none
            else
              :name
            end
          else
            :still_cannot_find_their_details
          end
        end

        # def next_step
        #   if wizard.participant_exists?
        #     if wizard.already_enrolled_at_school?
        #       :already_enrolled_at_school
        #     else
        #       :confirm_transfer
        #     end
        #   elsif wizard.found_participant_in_dqt? || wizard.sit_mentor?
        #     :none
        #   else
        #     :still_cannot_find_their_details
        #   end
        # end

        # def previous_step
        #   :cannot_find_their_details
        # end

        def journey_complete?
          next_step == :none
        end
      end
    end
  end
end
