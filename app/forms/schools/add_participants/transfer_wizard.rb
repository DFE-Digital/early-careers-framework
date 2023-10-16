# frozen_string_literal: true

module Schools
  module AddParticipants
    class TransferWizard < BaseWizard
      def self.steps
        %i[
          continue_current_programme
          join_school_programme
          cannot_add_manual_transfer
          email
          yourself
          email_already_taken
          joining_date
          choose_mentor
          confirm_appropriate_body
          check_answers
          complete
        ]
      end

      def do_not_continue_current_programme!
        data_store.set(:continue_current_programme, false)
      end

      def do_not_join_school_programme!
        data_store.set(:join_school_programme, nil)
      end

      def needs_to_choose_school_programme?
        return do_not_join_school_programme! if continue_current_programme?
        return true if [lead_provider, delivery_partner].all?

        [current_cohort_lead_provider, current_cohort_delivery_partner].all?
      end

      def needs_to_confirm_programme?
        return do_not_continue_current_programme! if withdrawn_participant?
        return do_not_continue_current_programme! if [existing_lead_provider, existing_delivery_partner].any?(&:blank?)

        true
      end

      def show_training_provider_section?
        !withdrawn_participant?
      end

      def save!
        save_progress!

        if form.journey_complete?
          # record whether provider changing
          set_participant_profile(transfer_participant!)
          complete!
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
        else
          show_path_for(step: form.next_step.to_s.dasherize)
        end
      end

      def show_path_for(step:)
        schools_transfer_show_path(**path_options(step:))
      end

      def previous_step_path
        back_step = last_visited_step
        return abort_path if back_step.nil?

        if changing_answer? || back_step != :confirm_transfer
          super
        else
          schools_who_to_add_show_path(**path_options(step: back_step))
        end
      end

      def abandon_path
        school_participants_path
      end

      def change_path_for(step:)
        schools_transfer_show_change_path(**path_options(step:))
      end

      def needs_to_choose_a_mentor?
        ect_participant? && mentor_id.blank? && mentor_options.any?
      end

      def check_for_dqt_record?
        full_name.present? && trn.present? && date_of_birth.present?
      end

      def after_user_dedup_sign_in_needed
        data_store.get(:after_user_dedup_sign_in_needed)
      end

      def current_user
        data_store.get(:current_user)
      end

      def sit_added_as_mentor?
        data_store.get(:sit_added_as_mentor)
      end

    private

      def transfer_participant!
        profile = existing_participant_profile
        data_store.set(:was_withdrawn_participant, withdrawn_participant?)
        new_induction_record = if sit_adding_themself_as_existing_mentor?
                                 transfer_sit_to_mentor_profile
                               elsif continue_current_programme?
                                 transfer_fip_participant_and_continue_existing_programme(profile)
                               else
                                 transfer_fip_participant_to_schools_programme(profile)
                               end

        send_notification_emails!(new_induction_record, was_withdrawn_participant?)
        profile
      end

      def withdrawn_participant?
        existing_participant_profile.training_status_withdrawn? || existing_induction_record&.training_status_withdrawn?
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

      def transfer_fip_participant_to_schools_programme(profile)
        chosen_school_cohort = join_current_cohort_school_programme? ? school_current_cohort : school_cohort

        # debugger
        Induction::TransferToSchoolsProgramme.call(
          participant_profile: profile,
          induction_programme: chosen_school_cohort.default_induction_programme,
          start_date:,
          email:,
          mentor_profile:,
        )
      end

      def transfer_sit_to_mentor_profile
        existing_profile = find_existing_mentor_by_trn
        profile = Mentors::TransferExistingMentorToSit.call(sit_user: current_user, mentor_profile: existing_profile, school_cohort:, start_date:)
        data_store.set(:after_user_dedup_sign_in_needed, true)
        data_store.set(:sit_added_as_mentor, true)
        data_store.set(:current_user, profile.user)
        profile.induction_records.latest
      end

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
          same_delivery_partner: same_delivery_partner?,
          same_provider: same_provider?,
          switch_to_schools_programme: needs_to_choose_school_programme?,
          lead_provider_profiles_in:,
          lead_provider_profiles_out:,
        )
      end
    end
  end
end
