# frozen_string_literal: true

module Schools
  module AddParticipants
    class AddWizard < BaseWizard
      def self.steps
        %i[
          email
          email_already_taken
          start_date
          start_term
          cannot_add_registration_not_yet_open
          cannot_add_yourself_as_ect
          cannot_add_mentor_to_providers
          yourself
          need_training_setup
          choose_mentor
          confirm_appropriate_body
          choose_partnership
          check_answers
          complete
        ]
      end

      def chosen_lead_provider
        previous_providers? ? previous_cohort_lead_provider : lead_provider
      end

      def chosen_delivery_partner
        previous_providers? ? previous_cohort_delivery_partner : delivery_partner
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
          elsif form.evaluate_next_step_on_change? # the change has produced a hard stop
            show_path_for(step: form.next_step)
          elsif email.present?
            show_path_for(step: :check_answers)
          else
            show_path_for(step: :email)
          end
        else
          show_path_for(step: form.next_step)
        end
      end

      def previous_step_path
        back_step = last_visited_step
        return abort_path if back_step.nil?

        if changing_answer? || back_step != :date_of_birth
          super
        else
          schools_who_to_add_show_path(**path_options(step: back_step))
        end
      end

      def show_path_for(step:)
        schools_add_show_path(**path_options(step:))
      end

      def change_path_for(step:)
        schools_add_show_change_path(**path_options(step:))
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

      def needs_to_choose_partnership?
        mentor_participant? && ([lead_provider, delivery_partner].all? || previous_providers_training_on_current_cohort?)
      end

      def start_term_description
        "#{start_term.capitalize} #{start_term == 'spring' ? Time.zone.now.year + 1 : Time.zone.now.year}"
      end

      def sit_added_as_mentor?
        participant_create_args[:email] == current_user.email
      end

    private

      def add_participant!
        # Finish enroll process and send notification emails
        profile = nil
        ActiveRecord::Base.transaction do
          profile = if ect_mentor?
                      Mentors::AddProfileToECT.call(ect_profile: existing_participant_profile,
                                                    school_cohort:,
                                                    induction_programme: mentor_induction_programme,
                                                    preferred_email: email)
                    elsif ect_participant?
                      reactivate_or_create_ect_profile
                    else
                      reactivate_or_create_mentor_profile
                    end

          store_validation_result!(profile)
        end

        send_added_and_validated_email(profile) if profile && profile.ecf_participant_validation_data.present? && !sit_mentor?

        profile
      end

      def mentor_induction_programme
        previous_providers? ? create_programme_with_previous_providers : programme
      end

      def create_programme_with_previous_providers
        partnership = Induction::CreateRelationship.call(school_cohort:,
                                                         lead_provider: previous_cohort_lead_provider,
                                                         delivery_partner: previous_cohort_delivery_partner)
        InductionProgramme.full_induction_programme.create!(school_cohort:, partnership:)
      end

      def reactivate_or_create_ect_profile
        existing_profile = ::Participants::WithdrawnProfileFinder.find(trn:, email:, type: :ect)

        if existing_profile
          args = participant_create_args.except(:full_name)
          EarlyCareerTeachers::Reactivate.call(participant_profile: existing_profile, **args)
        else
          EarlyCareerTeachers::Create.call(**participant_create_args)
        end
      end

      def reactivate_or_create_mentor_profile
        args = participant_create_args.except(:induction_start_date, :mentor_profile_id)

        existing_profile = ::Participants::WithdrawnProfileFinder.find(trn:, email:, type: :mentor)
        if existing_profile
          args = args.except(:full_name)
          Mentors::Reactivate.call(participant_profile: existing_profile,
                                   induction_programme: mentor_induction_programme,
                                   **args)
        else
          Mentors::Create.call(induction_programme: mentor_induction_programme, **args)
        end
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
        # appears perhaps the SIT doesn't always choose add mentor profile to self or perhaps
        # rare occaision where there are multiple SITs and one is adding to another
        unless profile.user.induction_coordinator?
          ParticipantMailer.with(
            participant_profile: profile,
            school_name: school.name,
          ).sit_has_added_and_validated_participant.deliver_later
        end
      end

      def participant_create_args
        {
          full_name:,
          email:,
          school_cohort:,
          mentor_profile_id: mentor_profile&.id,
          appropriate_body_id:,
          induction_start_date:,
        }
      end
    end
  end
end
