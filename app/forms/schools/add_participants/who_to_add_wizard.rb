# frozen_string_literal: true

module Schools
  module AddParticipants
    class WhoToAddWizard < BaseWizard
      def self.steps
        %i[
          participant_type
          yourself
          what_we_need
          name
          trn
          cannot_add_mentor_without_trn
          cannot_add_ect_because_already_a_mentor
          cannot_add_mentor_because_already_an_ect
          date_of_birth
          known_by_another_name
          different_name
          cannot_find_their_details
          nino
          still_cannot_find_their_details
          confirm_transfer
          confirm_mentor_transfer
          need_training_setup
          cannot_add
          cannot_add_mismatch
          cannot_add_mentor_at_multiple_schools
          cannot_add_already_enrolled_at_school
        ]
      end

      def save!
        save_progress!
      end

      def sit_can_become_a_mentor?
        !current_user.mentor?
      end

      # has this school got a cohort set up for training that matches the incoming transfer
      def need_training_setup?
        destination_cohort = school.school_cohorts.find_by(cohort: cohort_to_place_participant)
        destination_cohort.blank? || !destination_cohort.full_induction_programme?
      end

      # path to the most appropriate start point to set up training for the transfer
      def need_training_path
        if existing_participant_cohort == Cohort.active_registration_cohort
          expect_any_ects_schools_setup_school_cohort_path(school_id: school.slug, cohort_id: existing_participant_cohort)
        else
          schools_choose_programme_path(school_id: school.slug, cohort_id: existing_participant_cohort)
        end
      end

      def next_step_path
        next_step = form.next_step

        if next_step == :done
          next_journey_path
        elsif changing_answer?
          change_path_for(step: next_step)
        else
          show_path_for(step: next_step)
        end
      end

      def next_step_from_record_check
        if participant_exists?
          if dqt_record_has_different_name? && participant_has_different_name?
            :known_by_another_name
          elsif existing_participant_is_a_different_type?
            if ect_participant?
              # trying to add an ECT who is already a mentor
              :cannot_add_ect_because_already_a_mentor
            else
              # trying to add a mentor who is already an ECT
              :cannot_add_mentor_because_already_an_ect
            end
          elsif already_enrolled_at_school?
            :cannot_add_already_enrolled_at_school
          elsif ect_participant?
            :confirm_transfer
          else
            :confirm_mentor_transfer
          end
        elsif dqt_record_has_different_name?
          :known_by_another_name
        else
          :done
        end
      end

      def next_journey_path
        if transfer?
          schools_transfer_start_path(**path_options)
        elsif sit_mentor?
          schools_add_sit_start_path(**path_options)
        else
          schools_add_start_path(**path_options)
        end
      end

      def already_enrolled_at_school?
        existing_induction_record.school == school
      end

      def show_path_for(step:)
        schools_who_to_add_show_path(**path_options(step:))
      end

      def change_path_for(step:)
        schools_who_to_add_show_change_path(**path_options(step:))
      end

      def reset_known_by_another_name_response
        data_store.set(:known_by_another_name, nil)
      end

      def dqt_record_has_different_name?
        check_for_dqt_record? && !dqt_validation.name_matches?
      end

      def participant_has_different_name?
        !NameMatcher.new(existing_participant_profile.full_name, full_name).matches?
      end

      def participant_exists?
        # NOTE: this doesn't differentiate being at this school from being at another school
        existing_participant_profile.present?
      end

      def existing_participant_is_a_different_type?
        participant_exists? && existing_participant_profile.participant_type != participant_type.to_sym
      end
    end
  end
end
