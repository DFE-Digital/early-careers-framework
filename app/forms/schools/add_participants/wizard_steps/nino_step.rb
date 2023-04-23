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
            if wizard.participant_exists?
              if wizard.dqt_record_has_different_name? && wizard.participant_has_different_name?
                :known_by_another_name
              elsif wizard.existing_participant_is_a_different_type?
                if wizard.ect_participant?
                  # trying to add an ECT who is already a mentor
                  :cannot_add_ect_because_already_a_mentor
                else
                  # trying to add a mentor who is already an ECT
                  :cannot_add_mentor_because_already_an_ect
                end
              elsif wizard.already_enrolled_at_school?
                :cannot_add_already_enrolled_at_school
              elsif wizard.ect_participant?
                :confirm_transfer
              else
                :confirm_mentor_transfer
              end
            elsif wizard.dqt_record_has_different_name?
              :known_by_another_name
            else
              :none
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
