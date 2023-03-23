# frozen_string_literal: true

module Schools
  module AddParticipants
    class TransferWizard < BaseWizard
      def self.steps
        %i[
          continue_current_programme
          join_school_programme
          email
          email_already_taken
          joining_date
          choose_mentor
          confirm_appropriate_body
          check_answers
          confirmation
        ]
      end

      def needs_to_confirm_programme?
        lead_provider != existing_lead_provider || delivery_partner != existing_delivery_partner
      end

      def switching_programme?
        chose_to_join_school_programme? && !chose_to_continue_current_programme?
      end

      def chose_to_join_school_programme?
        transfer? && join_school_programme?
      end

      def chose_to_continue_current_programme?
        transfer? && continue_current_programme?
      end

      def save!
        save_progress!

        if form.journey_complete?
          @participant_profile = transfer_participant!
        end
      end

      def next_step_path
        if changing_answer?
          if dqt_record(force_recheck: true).present?
            if email.present?
              show_path_for(step: "check-answers")
            else
              show_path_for(step: "email")
            end
          else
            show_path_for(step: "cannot-find-their-details")
          end
        elsif form.journey_complete?
          complete_schools_transfer_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                      school_id: school_cohort.school.friendly_id,
                                                      participant_profile_id: participant_profile.id)
        else
          show_path_for(step: form.next_step.to_s.dasherize)
        end
      end

      def show_path_for(step:)
        show_schools_transfer_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                school_id: school_cohort.school.friendly_id,
                                                step:)
      end

      def previous_step_path
        back_step = form.previous_step

        if changing_answer? || back_step != :confirm_transfer
          super
        else
          # return to previous wizard
          show_schools_who_to_add_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                    school_id: school.friendly_id,
                                                    step: back_step.to_s.dasherize)
        end
      end

      def abandon_path
        schools_participants_path
      end

      def change_path_for(step:)
        show_change_schools_transfer_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                       school_id: school_cohort.school.friendly_id,
                                                       step:)
      end

      def needs_to_choose_a_mentor?
        ect_participant? && mentor_id.blank? && mentor_options.any?
      end

      def check_for_dqt_record?
        full_name.present? && trn.present? && date_of_birth.present?
      end

    private

      def transfer_participant!
        profile = existing_participant_profile
        was_withdrawn_participant = withdrawn_participant?

        new_induction_record = if transfer_has_the_same_provider? || was_withdrawn_participant
                                 transfer_fip_participant_to_schools_programme(profile)
                               elsif chose_to_join_school_programme?
                                 transfer_fip_participant_to_schools_programme(profile)
                               else
                                 transfer_fip_participant_and_continue_existing_programme(profile)
                               end

        send_notification_emails!(new_induction_record, was_withdrawn_participant)
        profile
      end

      def withdrawn_participant?
        existing_participant_profile.training_status_withdrawn? || existing_induction_record&.training_status_withdrawn?
      end

      def transfer_fip_participant_to_schools_programme(profile)
        Induction::TransferToSchoolsProgramme.call(
          participant_profile: profile,
          induction_programme: school_cohort.default_induction_programme,
          start_date:,
          email:,
          mentor_profile:,
        )
      end

      def transfer_fip_participant_and_continue_existing_programme(profile)
        Induction::TransferAndContinueExistingFip.call(
          school_cohort:,
          participant_profile: profile,
          email:,
          start_date:,
          end_date: start_date,
          mentor_profile:,
        )
      end

      # def transfer_has_same_provider_and_different_delivery_partner?
      #   transfer_has_the_same_provider? && !transfer_has_the_same_delivery_partner?
      # end

      # def transfer_has_the_same_provider?
      #   lead_provider == existing_lead_provider
      # end

      # def transfer_has_the_same_delivery_partner?
      #   delivery_partner == existing_delivery_partner
      # end

      # This methods assumes that all transfers are requested by the incoming school for now. There
      # are three paths here:
      #
      # 1) Moving schools but lead provider is same at both schools:
      #
      #   a. Send email to existing lead provider notifying them that an internal
      #      transfer is happening.
      #   b. Send email to participant to notify them.
      #
      # 2) Moving to target schools lead provider and programme:
      #
      #   a. Send email to incoming lead provider.
      #   b. Send email to outgoing lead provider, requesting that they withdraw them.
      #   c. Send email to participant to notify them.
      #
      # 3) Moving to target school, but continuing with current lead provider.
      #
      #   a. Send email to current lead provider, notifying them to expect a new school.
      #   b. Send email to participant to notify them.
      #
      def send_notification_emails!(new_induction_record, was_withdrawn_participant)
        lead_provider_profiles_in = lead_provider&.users&.map(&:lead_provider_profile) || []
        lead_provider_profiles_out = existing_lead_provider&.users&.map(&:lead_provider_profile) || []

        Induction::SendTransferNotificationEmails.call(
          induction_record: new_induction_record,
          was_withdrawn_participant:,
          same_delivery_partner: transfer_has_the_same_delivery_partner?,
          same_provider: transfer_has_the_same_provider?,
          switch_to_schools_programme: switching_programme?,
          lead_provider_profiles_in:,
          lead_provider_profiles_out:,
        )
      end

      # def store_validation_result!(profile)
      #   ::Participants::ParticipantValidationForm.call(
      #     profile,
      #     data: {
      #       trn: formatted_trn,
      #       nino: formatted_nino,
      #       date_of_birth:,
      #       full_name:,
      #     },
      #   )
      # end

      # def send_added_and_validated_email(profile)
      #   ParticipantMailer.sit_has_added_and_validated_participant(participant_profile: profile, school_name: school_cohort.school.name).deliver_later
      # end

      # def participant_create_args
      #   {
      #     full_name:,
      #     email:,
      #     school_cohort:,
      #     mentor_profile_id:,
      #     start_date:,
      #     sit_validation: true,
      #     appropriate_body_id:,
      #   }
      # end

      # def dqt_record(force_recheck: false)
      #   @dqt_record = nil if force_recheck

      #   @dqt_record ||= ParticipantValidationService.validate(
      #     full_name:,
      #     trn: formatted_trn,
      #     date_of_birth:,
      #     nino: formatted_nino,
      #     config: {
      #       check_first_name_only: true,
      #     },
      #   )
      # end

      # def load_current_user_into_current_state
      #   current_state["current_user"] = current_user
      # end

      # def load_from_current_state
      #   current_state.slice(*form_class.permitted_params.map(&:to_s))
      # end

      # def form_class
      #   @form_class ||= form_class_for(current_step)
      # end

      # def form_class_for(step)
      #   "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize
      # end

      # def build_form
      #   hash = load_from_current_state
      #   hash.merge!(submitted_params)
      #   hash.merge!(wizard: self)

      #   form_class.new(hash)
      # end

      # def set_current_step(step)
      #   @current_step = steps.find { |s| s == step.to_sym }

      #   raise InvalidStep, "Could not find step: #{step}" if @current_step.nil?
      # end

      # def formatted_nino
      #   NationalInsuranceNumber.new(nino).formatted_nino
      # end

      # def formatted_trn
      #   TeacherReferenceNumber.new(trn).formatted_trn
      # end
    end
  end
end
