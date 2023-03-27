# frozen_string_literal: true

module Schools
  module AddParticipants
    class AddWizard < BaseWizard
      def self.steps
        %i[
          email
          email_already_taken
          start_date
          choose_mentor
          confirm_appropriate_body
          check_answers
          complete
        ]
      end

      def save!
        save_progress!

        if form.journey_complete?
          set_participant_profile(add_participant!)
          complete!
        end
      end

      def next_step_path
        if changing_answer?
          if form.revisit_next_step?
            change_path_for(step: form.next_step)
          elsif email.present?
            show_path_for(step: :check_answers)
          else
            show_path_for(step: :email)
          end
        # elsif form.journey_complete?
        #   complete_schools_add_participants_path(cohort_id: school_cohort.cohort.start_year,
        #                                          school_id: school_cohort.school.friendly_id,
        #                                          participant_profile_id: participant_profile.id)
        else
          show_path_for(step: form.next_step)
        end
      end

      def previous_step_path
        back_step = form.previous_step

        if changing_answer? || back_step != :date_of_birth
          super
        else
          # return to previous wizard
          show_schools_who_to_add_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                    school_id: school.friendly_id,
                                                    step: back_step.to_s.dasherize)
        end
      end

      def show_path_for(step:)
        show_schools_add_participants_path(cohort_id: school_cohort.cohort.start_year,
                                           school_id: school.friendly_id,
                                           step: step.to_s.dasherize)
      end

      def change_path_for(step:)
        show_change_schools_add_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                  school_id: school_cohort.school.friendly_id,
                                                  step:)
      end

      def found_participant_in_dqt?
        check_for_dqt_record? && dqt_record.present?
      end

      def participant_exists?
        # NOTE: this doesn't differentiate being at this school from being at another school
        check_for_dqt_record? && dqt_record.present? && existing_participant_profile.present?
      end

      def check_for_dqt_record?
        full_name.present? && trn.present? && date_of_birth.present?
      end

      ## ECT journey
      def needs_to_choose_a_mentor?
        ect_participant? && mentor_id.blank? && mentor_options.any?
      end

    private

      def add_participant!
        # Finish enroll process and send notification emails
        profile = nil
        ActiveRecord::Base.transaction do
          profile = if ect_participant?
                      EarlyCareerTeachers::Create.call(**participant_create_args)
                    else
                      Mentors::Create.call(**participant_create_args)
                    end

          store_validation_result!(profile)
        end

        send_added_and_validated_email(profile) if profile && profile.ecf_participant_validation_data.present? && !sit_mentor?

        profile
      end

      def store_validation_result!(profile)
        ::Participants::ParticipantValidationForm.call(
          profile,
          data: {
            trn: formatted_trn,
            nino: formatted_nino,
            date_of_birth:,
            full_name:,
          },
        )
      end

      def send_added_and_validated_email(profile)
        ParticipantMailer.sit_has_added_and_validated_participant(participant_profile: profile, school_name: school_cohort.school.name).deliver_later
      end

      def participant_create_args
        {
          full_name:,
          email:,
          school_cohort:,
          mentor_profile_id: mentor_profile&.id,
          start_date:,
          sit_validation: true,
          appropriate_body_id:,
        }
      end
    end
  end
end
