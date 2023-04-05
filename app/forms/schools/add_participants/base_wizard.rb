# frozen_string_literal: true

module Schools
  module AddParticipants
    class BaseWizard
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      class AlreadyInitialised < StandardError; end
      class InvalidStep < StandardError; end

      attr_reader :current_step, :submitted_params, :data_store, :current_user, :school, :participant_profile

      delegate :before_render, to: :form
      delegate :view_name, to: :form
      delegate :after_render, to: :form

      delegate :return_point, :changing_answer?, :transfer?, :participant_type, :trn, :confirmed_trn, :date_of_birth,
               :start_date, :nino, :ect_participant?, :mentor_id, :continue_current_programme?, :participant_profile,
               :sit_mentor?, :mentor_participant?, :appropriate_body_confirmed?, :appropriate_body_id, :known_by_another_name?,
               :same_provider?, :was_withdrawn_participant?, :complete?,
               to: :data_store

      def initialize(current_step:, data_store:, current_user:, school:, submitted_params: {})
        if data_store.store.empty? && !(current_step.to_sym.in? %i[participant_type yourself])
          raise InvalidStep, "store empty (#{data_store.store.empty?} - current_step: #{current_step})"
        elsif !data_store.current_user.nil? && data_store.current_user != current_user ||
            !data_store.school_cohort_id.nil? && data_store.school_cohort_id != school_cohort.id
          raise AlreadyInitialised, "current_user or school_cohort different"
        end

        set_current_step(current_step)
        @current_user = current_user
        @data_store = data_store
        @school = school
        @submitted_params = submitted_params
        @participant_profile = nil
        @email_owner = nil
        @return_point = nil

        load_current_user_and_cohort_into_data_store
      end

      def self.permitted_params_for(step)
        "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
      end

      def abort_path
        schools_participants_path(cohort_id: school_cohort.cohort.start_year,
                                  school_id: school.slug)
      end

      def previous_step_path
        if changing_answer?
          show_path_for(step: return_point)
        else
          back_step = form.previous_step
          if back_step == :abort
            abort_path
          else
            show_path_for(step: back_step)
          end
        end
      end

      def ect_or_mentor_label
        if ect_participant?
          "ECT"
        else
          "Mentor"
        end
      end

      def full_name
        if sit_mentor?
          current_user.full_name
        else
          data_store.full_name
        end
      end

      def email
        if sit_mentor?
          current_user.email
        else
          data_store.email
        end
      end

      def join_school_programme?
        withdrawn_participant? || data_store.join_school_programme?
      end

      def not_known_by_another_name?
        # only true if responded to question with no
        data_store.get(:known_by_another_name) == "no"
      end

      # def school
      #   @school ||= school_cohort.school
      # end

      def lead_provider
        @lead_provider ||= @school_cohort.default_induction_programme&.lead_provider
      end

      def delivery_partner
        @delivery_partner ||= @school_cohort.default_induction_programme&.delivery_partner
      end

      def email_in_use?
        @email_owner ||= Identity.find_user_by(email: data_store.email)
        return false if @email_owner.nil?
        return true unless transfer?

        @email_owner != existing_user
      end

      def email_used_in_the_same_school?
        if email_in_use?
          participant_profile = @email_owner.teacher_profile&.ecf_profiles&.first
          if participant_profile
            Induction::FindBy.call(participant_profile:)&.school == school
          else
            false
          end
        else
          false
        end
      end

      ## handling transfers
      def existing_induction_start_date
        existing_induction_record.schedule.milestones.first.start_date
      end

      def existing_induction_record
        @existing_induction_record ||= Induction::FindBy.call(participant_profile: existing_participant_profile)
      end

      def existing_participant_profile
        @existing_participant_profile ||= TeacherProfile.joins(:ecf_profiles).where(trn: formatted_confirmed_trn).first&.ecf_profiles&.first
      end

      def existing_user
        @existing_user ||= existing_participant_profile&.user
      end

      def existing_participant_cohort
        @existing_participant_cohort ||= existing_induction_record.cohort
      end

      def existing_lead_provider
        @existing_lead_provider ||= existing_induction_record.lead_provider
      end

      def existing_delivery_partner
        @existing_delivery_partner ||= existing_induction_record.delivery_partner
      end

      def withdrawn_participant?
        existing_participant_profile.training_status_withdrawn? || existing_induction_record.training_status_withdrawn?
      end

      def transfer_has_same_providers?
        transfer_has_the_same_provider? && transfer_has_the_same_delivery_partner?
      end

      def transfer_has_same_provider_and_different_delivery_partner?
        transfer_has_the_same_provider? && !transfer_has_the_same_delivery_partner?
      end

      def transfer_has_the_same_provider?
        lead_provider == existing_lead_provider
      end

      def transfer_has_the_same_delivery_partner?
        delivery_partner == existing_delivery_partner
      end

      def set_same_provider(using_same_provider)
        data_store.set(:same_provider, using_same_provider)
      end

      ## appropriate bodies
      def needs_to_confirm_appropriate_body?
        ect_participant? && school_cohort.appropriate_body.present?
      end

      def appropriate_body_confirmed=(confirmed)
        data_store.set(:appropriate_body_confirmed, (confirmed ? "1" : "0"))
      end

      def appropriate_body_id=(value)
        data_store.set(:appropriate_body_id, value)
      end

      def appropriate_body_selected
        if appropriate_body_confirmed?
          school_cohort.appropriate_body
        elsif appropriate_body_id
          AppropriateBody.find(appropriate_body_id)
        end
      end

      # for completion
      def complete!
        data_store.set(:complete, true)
      end

      # set after add or transfer completed
      def set_participant_profile(profile)
        data_store.set(:participant_profile, profile)
      end

      def form_scope
        "add_participant_wizard"
      end

      def save_progress!
        form.before_save

        form.attributes.each do |k, v|
          data_store.set(k, v)
        end

        form.after_save
      end

      def set_current_step(step)
        @current_step = self.class.steps.find { |s| s == step.to_sym }

        raise InvalidStep, "Could not find step: #{step}" if @current_step.nil?
      end

      def check_for_dqt_record?
        full_name.present? && trn.present? && date_of_birth.present?
      end

      def found_participant_in_dqt?
        check_for_dqt_record? && dqt_record.present?
      end

      def dqt_record(force_recheck: false)
        @dqt_record = nil if force_recheck

        @dqt_record ||= validate_details
      end

      def validate_details
        record = ParticipantValidationService.validate(
          full_name:,
          trn: formatted_trn,
          date_of_birth:,
          nino: formatted_nino,
          config: { check_first_name_only: true },
        )
        set_confirmed_trn(record[:trn]) if record
        record
      end

      def set_confirmed_trn(trn_value)
        data_store.set(:confirmed_trn, TeacherReferenceNumber.new(trn_value).formatted_trn)
      end

      def dqt_record_check(force_recheck: false)
        @dqt_record_check = nil if force_recheck

        @dqt_record_check ||= DqtRecordCheck.call(
          full_name:,
          trn: formatted_trn,
          date_of_birth:,
          nino: formatted_nino,
        )
      end

      def formatted_nino
        NationalInsuranceNumber.new(nino).formatted_nino
      end

      def formatted_confirmed_trn
        TeacherReferenceNumber.new(confirmed_trn).formatted_trn
      end

      def formatted_trn
        TeacherReferenceNumber.new(trn).formatted_trn
      end

      def possessive_name_or_your
        if sit_mentor?
          "your"
        else
          possessive_name
        end
      end

      def possessive_name
        ApplicationController.helpers.possessive_name(full_name)
      end

      # mentor for ECT helpers
      def mentor_options
        @mentor_options ||= school.mentors
      end

      def mentor
        @mentor ||= (User.find(mentor_id) if mentor_id && mentor_id != "later")
      end

      def mentor_profile
        mentor&.mentor_profile
      end

      # handling check answers type checkpoints
      def set_return_point(step)
        data_store.set(:return_point, step)
      end

      def changing_answer(is_changing)
        data_store.set(:changing_answer, is_changing)
      end

      # set up form
      def form
        @form ||= build_form
      end

      def build_form
        hash = load_from_data_store
        hash.merge!(submitted_params)
        hash.merge!(wizard: self)

        form_class.new(hash)
      end

      def load_current_user_and_school_into_data_store
        data_store.set(:current_user, current_user)
        data_store.set(:school_id, school.slug)
      end

      def load_from_data_store
        data_store.bulk_get(form_class.permitted_params)
      end

      def form_for_step(step)
        step_form_class = form_class_for(step)
        hash = data_store.bulk_get(step_form_class.permitted_params)
        hash.merge!(wizard: self)
        step_form_class.new(hash)
      end

      def form_class
        @form_class ||= form_class_for(current_step)
      end

      def form_class_for(step)
        "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize
      end

      def reset_form
        %i[
          participant_type
          full_name
          trn
          confirmed_trn
          date_of_birth
          nino
          email
          mentor_id
          start_date
          appropriate_body_id
          appropriate_body_confirmed
          continue_current_programme
          join_school_programme
          transfer_confirmed
          known_by_another_name
          participant_profile
          same_provider
          complete
        ].each do |key|
          data_store.set(key, nil)
        end

        load_current_user_and_cohort_into_data_store
      end
    end
  end
end
