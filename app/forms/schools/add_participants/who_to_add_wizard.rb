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
          date_of_birth
          known_by_another_name
          different_name
          cannot_find_their_details
          nino
          still_cannot_find_their_details
          confirm_transfer
          confirm_mentor_transfer
          cannot_add
          cannot_add_mismatch
          cannot_add_mentor_at_multiple_schools
          already_enrolled_at_school
        ]
      end

      def save!
        save_progress!
      end

      # has this school got a cohort set up for training that matches the incoming transfer
      def need_training_setup?
        transfer_cohort = school.school_cohorts.find_by(cohort: existing_participant_cohort)
        transfer_cohort.blank? || !transfer_cohort.full_induction_programme?
      end

      # path to the most appropriate start point to set up training for the transfer
      def need_training_path
        if existing_participant_cohort == Cohort.active_registration_cohort
          expect_any_ects_schools_setup_school_cohort_path(cohort_id: existing_participant_cohort)
        else
          schools_choose_programme_path(cohort_id: participant_cohort)
        end
      end

      def next_step_path
        if changing_answer?
          if form.revisit_next_step?
            change_path_for(step: form.next_step)
          elsif dqt_record(force_recheck: true).present?
            next_journey_path
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
        path_opts = {
          cohort_id: school_cohort.cohort.start_year,
          school_id: school.friendly_id,
        }

        if transfer?
          start_schools_transfer_participants_path(**path_opts)
        else
          start_schools_add_participants_path(**path_opts)
        end
      end

      def already_enrolled_at_school?
        existing_induction_record.school == school
      end

      def show_path_for(step:)
        show_schools_who_to_add_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                  school_id: school.friendly_id,
                                                  step: step.to_s.dasherize)
      end

      def change_path_for(step:)
        show_change_schools_who_to_add_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                         school_id: school_cohort.school.friendly_id,
                                                         step:)
      end

      # def found_participant_in_dqt?
      #   check_for_dqt_record? && dqt_record.present?
      # end

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
        check_for_dqt_record? && dqt_record.present? && existing_participant_profile.present?
      end

      # def check_for_dqt_record?
      #   full_name.present? && trn.present? && date_of_birth.present?
      # end

    private

      # def dqt_record(force_recheck: false)
      #   @dqt_record = nil if force_recheck

      #   @dqt_record ||= validate_details
      # end

      # def validate_details
      #   record = ParticipantValidationService.validate(
      #     full_name:,
      #     trn: formatted_trn,
      #     date_of_birth:,
      #     nino: formatted_nino,
      #     config: { check_first_name_only: true },
      #   )
      #   set_confirmed_trn(record[:trn]) if record
      #   record
      # end

      # def set_confirmed_trn(trn_value)
      #   data_store.set(:confirmed_trn, TeacherReferenceNumber.new(trn_value).formatted_trn
      # end

      def dqt_record_check(force_recheck: false)
        @dqt_record_check = nil if force_recheck

        @dqt_record_check ||= DqtRecordCheck.call(
          full_name:,
          trn: formatted_trn,
          date_of_birth:,
          nino: formatted_nino,
        )
      end
    end
  end
end
