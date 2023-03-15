# frozen_string_literal: true

module Schools
  module AddParticipants
    class AddECTWizard < BaseWizard
      attr_reader :current_step, :submitted_params, :current_state, :current_user, :school_cohort, :participant_profile

      delegate :before_render, to: :form
      delegate :after_render, to: :form

      def initialize(current_step:, current_state:, current_user:, school_cohort:, submitted_params: {})
        set_current_step(current_step)

        @current_user = current_user
        @current_state = current_state
        @school_cohort = school_cohort
        @submitted_params = submitted_params
        @participant_profile = nil

        @return_point = nil

        load_current_user_into_current_state
      end

      def self.permitted_params_for(step)
        "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
      end

      def set_current_state(state)
        @current_state = state
        @form = build_form
      end

      def return_point
        (current_state["return_point"] ||= "").to_s.dasherize
      end

      def set_return_point(step)
        current_state["return_point"] = step
      end

      def form
        @form ||= build_form
      end

      def changing_answer(is_changing)
        current_state["changing_answer"] = is_changing
      end

      def changing_answer?
        current_state["changing_answer"] == true
      end

      def transfer?
        current_state["transfer_confirmed"] == "1"
      end

      def save!
        save_progress!

        if form.journey_complete?
          @participant_profile = add_participant!
        end
      end

      def existing_induction_start_date
        existing_induction_record.schedule.milestones.first.start_date
      end

      def existing_induction_record
        @existing_induction_record ||= existing_participant_profile.latest_induction_record
      end

      def existing_participant_profile
        @existing_participant_profile ||= TeacherProfile.joins(:ecf_profiles).where(trn: formatted_trn).first.ecf_profiles.first
      end

      def existing_participant_cohort
        @existing_participant_cohort ||= existing_induction_record.cohort
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
          else
            if dqt_record(force_recheck: true).present?
              if email.present?
                show_path_for(step: :check_answers)
              else
                show_path_for(step: :email)
              end
            else
              show_path_for(step: :cannot_find_their_details)
            end
          end
        else
          if form.journey_complete?
            complete_schools_add_ect_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                       school_id: school_cohort.school.friendly_id,
                                                       participant_profile_id: participant_profile.id)
          else
            show_path_for(step: form.next_step)
          end
        end
      end

      def show_path_for(step:)
        show_schools_add_ect_participants_path(cohort_id: school_cohort.cohort.start_year,
                                               school_id: school.friendly_id,
                                               step: step.to_s.dasherize)
      end

      def previous_step_path
        if changing_answer?
          return_point
        else
          form.previous_step.to_s.dasherize
        end
      end

      def abandon_path
        schools_participants_path
      end

      def change_path_for(step:)
        show_change_schools_add_ect_participants_path(cohort_id: school_cohort.cohort.start_year,
                                                      school_id: school_cohort.school.friendly_id,
                                                      step:)
      end

      def form_scope
        "add_ect_wizard"
      end

      def form_for_step(step)
        step_form_class = form_class_for(step)
        hash = current_state.slice(*step_form_class.permitted_params.map(&:to_s))
        hash.merge!(wizard: self)
        step_form_class.new(hash)
      end

      def possessive_name
        ApplicationController.helpers.possessive_name(full_name)
      end

      def full_name
        current_state["full_name"]
      end

      def trn
        current_state["trn"]
      end

      def date_of_birth
        current_state["date_of_birth"]
      end

      def start_date
        current_state["start_date"]
      end

      def email
        current_state["email"]
      end

      def nino
        current_state["nino"]
      end

      def ect_participant?
        true
      end

      def found_participant_in_dqt?
        check_for_dqt_record? && dqt_record.present?
      end

      def participant_exists?
        # NOTE: this doesn't differentiate being at this school from being at another school
        check_for_dqt_record? && dqt_record.present? && existing_participant_profile.present?
      end

      def needs_to_choose_a_mentor?
        ect_participant? && mentor_id.blank? && mentor_options.any?
      end

      def mentor_options
        @mentor_options ||= school.mentors
      end

      def mentor
        @mentor ||= (User.find(mentor_id) if mentor_id && mentor_id != "later")
      end

      def mentor_profile
        mentor&.mentor_profile
      end

      def mentor_id
        current_state["mentor_id"]
      end

      def switching_programme?
        joining_school_programme? && !continuing_current_programme? 
      end

      def joining_school_programme?
        transfer? && current_state["join_school_programme"] == "yes"
      end

      def continuing_current_programme?
        transfer? && current_state["continue_current_programme"] == "yes"
      end

      def needs_to_confirm_appropriate_body?
        ect_participant? && school_cohort.appropriate_body.present?
      end

      def appropriate_body_confirmed=(confirmed)
        current_state["appropriate_body_confirmed"] = (confirmed ? "1" : "0")
      end

      def appropriate_body_confirmed?
        current_state["appropriate_body_confirmed"] == "1"
      end

      def appropriate_body_id
        current_state["appropriate_body_id"]
      end

      def appropriate_body_id=(value)
        current_state["appropriate_body_id"] = value
      end

      def appropriate_body_selected
        if appropriate_body_confirmed?
          school_cohort.appropriate_body
        elsif appropriate_body_id
          AppropriateBody.find(appropriate_body_id)
        end
      end

      def check_for_dqt_record?
        full_name.present? && trn.present? && date_of_birth.present?
      end

      def reset_form
        current_state["participant_type"] = "ect"
        current_state["full_name"] = nil
        current_state["trn"] = nil
        current_state["date_of_birth"] = nil
        current_state["nino"] = nil
        current_state["email"] = nil
        current_state["mentor_id"] = nil
        current_state["start_date"] = nil
        current_state["appropriate_body_id"] = nil
        current_state["appropriate_body_confirmed"] = nil
        current_state["continue_current_programme"] = nil
        current_state["join_school_programme"] = nil
      end

      def lead_provider
        @lead_provider ||= @school_cohort.default_induction_programme&.lead_provider
      end

      def existing_lead_provider
        @existing_lead_provider ||= existing_induction_record.lead_provider
      end

      def delivery_partner
        @delivery_partner ||= @school_cohort.default_induction_programme&.delivery_partner
      end

      def existing_delivery_partner
        @existing_delivery_partner ||= existing_induction_record.delivery_partner
      end

      def needs_to_confirm_programme?
        lead_provider != existing_lead_provider || delivery_partner != existing_delivery_partner
      end

      def transfer_has_same_provider_and_different_delivery_partner?
        transfer_has_the_same_provider? && !transfer_has_the_same_delivery_partner?
      end

      def transfer_has_the_same_provider?
        lead_provider == existing_lead_provider
      end

      def with_the_same_delivery_partner?
        delivery_partner == existing_delivery_partner
      end

    private

      def school
        @school ||= school_cohort.school
      end

      def save_progress!
        form.before_save

        form.attributes.each do |k, v|
          current_state[k.to_s] = v
        end

        form.after_save
      end

      def add_participant!
        # Finish enroll process and send notification emails
        profile = nil
        if transfer?
          profile = existing_participant_profile
          was_withdrawn_participant = withdrawn_participant?

          new_induction_record = if transfer_has_the_same_provider? || was_withdrawn_participant
                                   transfer_fip_participant_to_schools_programme(profile)
                                 elsif joining_school_programme?
                                   transfer_fip_participant_to_schools_programme(profile)
                                 else
                                   transfer_fip_participant_and_continue_existing_programme(profile)
                                 end

          send_notification_emails!(new_induction_record, was_withdrawn_participant)
        else
          ActiveRecord::Base.transaction do
            profile = if ect_participant?
                        EarlyCareerTeachers::Create.call(**participant_create_args)
                      else
                        Mentors::Create.call(**participant_create_args)
                      end

            store_validation_result!(profile)
          end

          send_added_and_validated_email(profile) if profile && profile.ecf_participant_validation_data.present? && !sit_mentor?
        end

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

      def transfer_fip_participant_to_schools_programme(profile)
        Induction::TransferToSchoolsProgramme.call(
          participant_profile: profile,
          induction_programme: school_cohort.default_induction_programme,
          start_date: start_date,
          email: email,
          mentor_profile: mentor_profile,
        )
      end

      def transfer_fip_participant_and_continue_existing_programme(profile)
        Induction::TransferAndContinueExistingFip.call(
          school_cohort: school_cohort,
          participant_profile: profile,
          email:,
          start_date:,
          end_date: start_date,
          mentor_profile: mentor_profile,
        )
      end

      def withdrawn_participant?
        existing_participant_profile.training_status_withdrawn? || existing_induction_record.training_status_withdrawn?
      end

      def send_added_and_validated_email(profile)
        ParticipantMailer.sit_has_added_and_validated_participant(participant_profile: profile, school_name: school_cohort.school.name).deliver_later
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
          same_delivery_partner: transfer_has_the_same_delivery_partner?,
          same_provider: transfer_has_the_same_provider?,
          switch_to_schools_programme: switching_programme?,
          lead_provider_profiles_in:,
          lead_provider_profiles_out:,
        )
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

      def dqt_record(force_recheck: false)
        @dqt_record = nil if force_recheck

        @dqt_record ||= ParticipantValidationService.validate(
          full_name:,
          trn: formatted_trn,
          date_of_birth:,
          nino: formatted_nino,
          config: {
            check_first_name_only: true,
          },
        )
      end

      def load_current_user_into_current_state
        current_state["current_user"] = current_user
      end

      def load_from_current_state
        current_state.slice(*form_class.permitted_params.map(&:to_s))
      end

      def form_class
        @form_class ||= form_class_for(current_step)
      end

      def form_class_for(step)
        "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize
      end

      def build_form
        hash = load_from_current_state
        hash.merge!(submitted_params)
        hash.merge!(wizard: self)

        form_class.new(hash)
      end

      def set_current_step(step)
        @current_step = steps.find { |s| s == step.to_sym }

        raise InvalidStep, "Could not find step: #{step}" if @current_step.nil?
      end

      def formatted_nino
        NationalInsuranceNumber.new(nino).formatted_nino
      end

      def formatted_trn
        TeacherReferenceNumber.new(trn).formatted_trn
      end

      def steps
        %i[
          who
          yourself
          what_we_need
          name
          trn
          cannot_add_mentor_without_trn
          date_of_birth
          cannot_find_their_details
          nino
          still_cannot_find_their_details
          confirm_transfer
          cannot_add
          email
          start_date
          joining_date
          choose_mentor
          continue_current_programme
          join_school_programme
          confirm_appropriate_body
          check_answers
          confirmation
        ]
      end
    end
  end
end
