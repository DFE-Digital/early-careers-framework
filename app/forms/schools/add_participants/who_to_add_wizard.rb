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
          cannot_add_registration_not_yet_open
        ]
      end

      def save!
        save_progress!
      end

      def sit_can_become_a_mentor?
        !current_user.mentor?
      end

      def registration_open_for_participant_cohort?
        desired_cohort = cohort_to_place_participant

        return true if desired_cohort.start_year <= Cohort.current.start_year

        if Cohort.within_next_registration_period? && desired_cohort == Cohort.next
          FeatureFlag.active?(:cohortless_dashboard, for: school)
        else
          false
        end
      end

      def next_step_path
        if changing_answer?
          if form.revisit_next_step?
            change_path_for(step: form.next_step)
          elsif dqt_record(force_recheck: true).present?
            if form.journey_complete?
              next_journey_path
            else
              show_path_for(step: form.next_step)
            end
          else
            show_path_for(step: :cannot_find_their_details)
          end
        elsif form.journey_complete?
          next_journey_path
        else
          show_path_for(step: form.next_step)
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
        return false unless check_for_dqt_record?

        record = dqt_record_check
        record.present? && record.dqt_record.present? && !record.name_matches && record.total_matched >= 2
      end

      def participant_exists?
        # NOTE: this doesn't differentiate being at this school from being at another school
        check_for_dqt_record? && dqt_record(force_recheck: true).present? && existing_participant_profile.present?
      end

      def existing_participant_is_a_different_type?
        participant_exists? && existing_participant_profile.participant_type != participant_type.to_sym
      end
    end
  end
end
