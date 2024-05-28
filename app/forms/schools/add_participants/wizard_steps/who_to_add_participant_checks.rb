# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      module WhoToAddParticipantChecks
        def next_step_after_participant_check
          if wizard.participant_exists? && !wizard.participant_withdrawn?
            existing_participant_checks
          else
            new_participant_checks
          end
        end

        def existing_participant_checks
          if adding_a_mentor_profile_to_an_ect?
            wizard.set_ect_mentor
            cohort_checks
          elsif adding_an_ect_profile_to_a_mentor?
            :cannot_add_ect_because_already_a_mentor
          elsif wizard.already_enrolled_at_school_and_training? || wizard.already_enrolled_at_school_and_completed?
            :cannot_add_already_enrolled_at_school
          elsif wizard.already_enrolled_at_school_but_leaving?
            :cannot_add_already_enrolled_at_school_but_leaving
          elsif wizard.already_enrolled_at_school_but_withdrawn?
            :cannot_add_already_enrolled_at_school_but_withdrawn
          elsif wizard.already_enrolled_at_school_but_deferred?
            :cannot_add_already_enrolled_at_school_but_deferred
          else
            transfer_step_for_type
          end
        end

        def new_participant_checks
          if wizard.dqt_record_has_different_name?
            :known_by_another_name
          elsif wizard.found_participant_in_dqt? || wizard.sit_mentor?
            cohort_checks
          else
            :cannot_find_their_details
          end
        end

        def adding_a_mentor_profile_to_an_ect?
          wizard.existing_participant_is_a_different_type? && wizard.mentor_participant?
        end

        def adding_an_ect_profile_to_a_mentor?
          wizard.existing_participant_is_a_different_type? && wizard.ect_participant?
        end

        def transfer_step_for_type
          if wizard.ect_participant?
            :confirm_transfer
          else
            :confirm_mentor_transfer
          end
        end

        def cohort_checks
          if wizard.automatically_assign_next_cohort?
            :none
          elsif !wizard.registration_open_for_participant_cohort?
            # we know the cohort at this point (only if induction start date set)
            :cannot_add_registration_not_yet_open
          elsif wizard.need_training_setup?
            # check that there is a school_cohort to join (can be FIP or CIP)
            :need_training_setup
          else
            :none
          end
        end
      end
    end
  end
end
