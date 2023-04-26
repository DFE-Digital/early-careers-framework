# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      module WhoToAddParticipantChecks
        def next_step_after_participant_check
          if wizard.participant_exists?
            if wizard.existing_participant_is_a_different_type?
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
          elsif wizard.found_participant_in_dqt? || wizard.sit_mentor?
            # check that it's not for the next cohort (this would be if induction start date is set in the next cohort)
            if !wizard.registration_open_for_participant_cohort?
              :cannot_add_registration_not_yet_open
            elsif wizard.need_training_setup?(must_be_fip: false)
              # check that there is a school_cohort to join (can be FIP or CIP)
              :need_training_setup
            else
              :none
            end
          else
            :cannot_find_their_details
          end
        end
      end
    end
  end
end
