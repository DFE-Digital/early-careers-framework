# frozen_string_literal: true

module Schools
  module AddParticipants
    class BaseWizard
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      class AlreadyInitialised < StandardError; end

      class InvalidStep < StandardError; end

      attr_reader :current_step, :submitted_params, :data_store, :current_user, :participant_profile, :school

      delegate :before_render, to: :form
      delegate :view_name, to: :form
      delegate :after_render, to: :form

      delegate :return_point, :changing_answer?, :transfer?, :participant_type, :trn, :confirmed_trn, :date_of_birth,
               :induction_start_date, :nino, :ect_participant?, :mentor_id, :continue_current_programme?, :participant_profile,
               :mentor_participant?, :appropriate_body_confirmed?, :appropriate_body_id, :known_by_another_name?,
               :was_withdrawn_participant?, :complete?, :start_date, :last_visited_step,
               :ect_mentor?, :join_school_programme, :join_school_programme?, :join_participant_cohort_school_programme?,
               :join_current_cohort_school_programme?, :current_providers?, :previous_providers?, :providers_chosen?,
               :full_name, to: :data_store

      def initialize(current_step:, data_store:, current_user:, school:, submitted_params: {})
        @current_user = current_user
        @data_store = data_store
        @school = school
        @submitted_params = submitted_params
        @participant_profile = nil
        @email_owner = nil
        @return_point = nil
        @previous_step = nil

        set_current_step(current_step)

        check_data_store_state!
        data_store_should_not_have_a_different_user!
        data_store_should_not_have_a_different_school!

        load_current_user_and_school_into_data_store
      end

      def self.permitted_params_for(step)
        "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
      end

      def abort_path
        schools_dashboard_path(school_id: school.slug)
      end

      def dashboard_path
        schools_dashboard_path(school_id: school.slug)
      end

      def previous_step_path
        if changing_answer?
          show_path_for(step: return_point)
        else
          back_step = last_visited_step
          return abort_path if back_step.nil?

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

      def email
        if sit_mentor?
          current_user.email
        else
          data_store.email
        end
      end

      def set_ect_mentor
        data_store.set(:ect_mentor, true)
      end

      def not_known_by_another_name?
        # only true if responded to question with no
        data_store.get(:known_by_another_name) == "no"
      end

      def destination_school_cohort
        school.school_cohorts.find_by(cohort: cohort_to_place_participant)
      end

      def destination_school_cohort_needs_setup?
        destination_school_cohort.blank? || destination_school_cohort.no_early_career_teachers?
      end

      def fip_destination_school_cohort?
        destination_school_cohort.full_induction_programme?
      end

      # has this school got a cohort set up for training that matches the incoming transfer
      def need_training_setup?
        return true if destination_school_cohort_needs_setup?
        return false if destination_school_cohort.full_induction_programme?

        !destination_school_cohort.core_induction_programme?
      end

      # path to the most appropriate start point to set up training for the transfer
      def need_training_path
        if cohort_to_place_participant == Cohort.active_registration_cohort
          schools_cohort_setup_start_path(school_id: school.slug, cohort_id: cohort_to_place_participant)
        else
          schools_choose_programme_path(school_id: school.slug, cohort_id: cohort_to_place_participant)
        end
      end

      def school_cohort
        # determine this based on which cohort to place the participant in
        @school_cohort ||= school.school_cohorts.find_by(cohort: participant_cohort)
      end

      def school_current_cohort
        @school_current_cohort ||= school.school_cohorts.find_by(cohort: current_cohort) if current_cohort
      end

      def school_previous_cohort
        @school_previous_cohort ||= school.school_cohorts.find_by(cohort: previous_cohort) if previous_cohort
      end

      def current_cohort
        @current_cohort ||= Cohort.active_registration_cohort
      end

      def previous_cohort
        @previous_cohort ||= current_cohort&.previous
      end

      def current_cohort_lead_provider
        @current_cohort_lead_provider ||= current_cohort_partnership&.lead_provider
      end

      def current_cohort_delivery_partner
        @current_cohort_delivery_partner ||= current_cohort_partnership&.delivery_partner
      end

      def current_cohort_programme
        @current_cohort_programme ||= school_current_cohort.default_induction_programme
      end

      def current_cohort_partnership
        @current_cohort_partnership ||= current_cohort_programme&.partnership

        @current_cohort_partnership if @current_cohort_partnership&.active?
      end

      def current_providers_training_on_participant_cohort?
        return false unless [current_cohort_lead_provider, current_cohort_delivery_partner].all?

        ProviderRelationship.exists?(lead_provider: current_cohort_lead_provider,
                                     delivery_partner: current_cohort_delivery_partner,
                                     cohort: participant_cohort)
      end

      def previous_providers_training_on_current_cohort?
        return false unless [previous_cohort_lead_provider, previous_cohort_delivery_partner].all?

        ProviderRelationship.exists?(lead_provider: previous_cohort_lead_provider,
                                     delivery_partner: previous_cohort_delivery_partner,
                                     cohort: current_cohort)
      end

      def lead_provider
        @lead_provider ||= partnership&.lead_provider
      end

      def delivery_partner
        @delivery_partner ||= partnership&.delivery_partner
      end

      def programme
        @programme ||= school_cohort&.default_induction_programme
      end

      def partnership
        @partnership ||= programme&.partnership

        @partnership if @partnership&.active?
      end

      def previous_cohort_lead_provider
        @previous_cohort_lead_provider ||= previous_cohort_partnership&.lead_provider
      end

      def previous_cohort_delivery_partner
        @previous_cohort_delivery_partner ||= previous_cohort_partnership&.delivery_partner
      end

      def previous_cohort_programme
        @previous_cohort_programme ||= school_previous_cohort&.default_induction_programme
      end

      def previous_cohort_partnership
        @previous_cohort_partnership ||= previous_cohort_programme&.partnership

        @previous_cohort_partnership if @previous_cohort_partnership&.active?
      end

      def email_in_use?
        @email_owner ||= Identity.find_user_by(email: data_store.email)
        return false if @email_owner.nil?

        if ect_mentor?
          # email_owner must be the same as existing ECT user
          return @email_owner != existing_user
        end

        return false unless @email_owner.participant?

        return false if adding_ect_as_mentor?

        return true unless transfer?

        @email_owner != existing_user
      end

      def using_sit_email?
        data_store.email == current_user.email
      end

      def sit_adding_themself_as_mentor?
        using_sit_email? && participant_type == "mentor"
      end

      alias_method :sit_mentor?, :sit_adding_themself_as_mentor?

      def find_existing_mentor_by_trn
        teacher_profile = TeacherProfile.find_by(trn:)
        return if teacher_profile.nil?

        teacher_profile.ecf_profiles.mentors.first
      end

      def sit_adding_themself_as_existing_mentor?
        sit_adding_themself_as_mentor? && find_existing_mentor_by_trn.present?
      end

      def adding_yourself_as_ect?
        using_sit_email? && participant_type == "ect"
      end

      def email_owner_participant_profile
        @email_owner.teacher_profile&.ecf_profiles&.first
      end

      def email_owner_induction_record_for_current_school
        return if email_owner_participant_profile.blank?

        Induction::FindBy.call(
          participant_profile: email_owner_participant_profile,
          school:,
        )
      end

      def email_used_in_the_same_school?
        return false unless email_in_use?

        email_owner_induction_record_for_current_school.present?
      end

      ## handling transfers
      def existing_induction_start_date
        existing_induction_record.schedule.milestones.first.start_date
      end

      def existing_induction_record
        @existing_induction_record ||= Induction::FindBy.call(participant_profile: existing_participant_profile)
      end

      def existing_participant_profile
        @existing_participant_profile ||=
          ParticipantProfile::ECF
            .joins(:teacher_profile)
            .where(teacher_profile: { trn: formatted_confirmed_trn })
            .first
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

      def same_provider?
        return lead_provider == existing_lead_provider if join_participant_cohort_school_programme?
        return current_cohort_lead_provider == existing_lead_provider if join_current_cohort_school_programme?

        false
      end

      def same_delivery_partner?
        return delivery_partner == existing_delivery_partner if join_participant_cohort_school_programme?
        return current_cohort_delivery_partner == existing_delivery_partner if join_current_cohort_school_programme?

        false
      end

      def automatically_assign_next_cohort?
        (mentor_participant? || induction_start_date.blank?) && !Cohort.within_automatic_assignment_period?
      end

      ## appropriate bodies
      def needs_to_confirm_appropriate_body?
        # Slim possiblity that school_cohort could be nil early on
        ect_participant? && school_cohort&.appropriate_body.present?
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

      def update_history
        previous = history_stack.last

        if changing_answer?
          # if changing the answer corrects the problem we will move straight on
          # to the next step so we do not want to keep the return point in the stack
          history_stack.pop if previous == return_point
        else
          if previous != current_step
            # on a new step
            if history_stack.second_to_last == current_step
              # we've gone back
              history_stack.pop
              previous = history_stack.second_to_last
            else
              # we've moved forward
              history_stack.push(current_step)
            end
          else
            previous = history_stack.second_to_last
          end
          data_store.set(:last_visited_step, previous)
          data_store.set(:history_stack, history_stack)
        end
      end

      def history_stack
        @history_stack ||= data_store.history_stack
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

        if record
          data_store.set(:confirmed_trn, TeacherReferenceNumber.new(record[:trn]).formatted_trn)
          data_store.set(:induction_start_date, record[:induction_start_date])
        else
          data_store.set(:confirmed_trn, nil)
          data_store.set(:induction_start_date, nil)
        end
        record
      end

      def dqt_record_check(force_recheck: false)
        @dqt_record_check = nil if force_recheck

        @dqt_record_check ||= DQTRecordCheck.call(
          full_name:,
          trn: formatted_trn,
          date_of_birth:,
          nino: formatted_nino,
        )
      end

      def participant_cohort
        @participant_cohort ||= cohort_to_place_participant
      end

      # NOTE: not preventing registration here just determining where to put the participant
      def cohort_to_place_participant
        return cohort_for_transfer if transfer?
        return cohort_for_ect_with_induction_start_date if ect_participant? && induction_start_date.present?

        Cohort.within_automatic_assignment_period? ? Cohort.current : Cohort.next
      end

      def cohort_for_ect_with_induction_start_date
        Cohort.for_induction_start_date(induction_start_date).tap do |cohort|
          return Cohort.current if cohort.blank? || cohort.npq_plus_one_or_earlier?
          return Cohort.active_registration_cohort if cohort.payments_frozen?
        end
      end

      def cohort_for_transfer
        cohort = Cohort.active_registration_cohort
        return cohort if existing_participant_profile&.eligible_to_change_cohort_and_continue_training?(cohort:)

        existing_participant_cohort || existing_participant_profile&.schedule&.cohort
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

      def full_name_or_you
        if sit_mentor?
          "you"
        else
          full_name
        end
      end

      def full_name_or_yourself
        if sit_mentor?
          "yourself"
        else
          full_name
        end
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

      def path_options(step: nil)
        path_opts = {
          school_id: school.slug,
        }

        path_opts[:step] = step.to_s.dasherize if step.present?
        path_opts
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
          history_stack
          last_visited_step
          school_cohort_id
          school_id
          ect_mentor
          providers
        ].each do |key|
          data_store.set(key, nil)
        end

        load_current_user_and_school_into_data_store
      end

      # sanity checks
      def check_data_store_state!
        if current_step.in? %i[participant_type]
          reset_form if submitted_params.empty?
        elsif data_store.store.empty?
          raise InvalidStep, "Datastore is empty at [#{current_step}]"
        end
      end

      def data_store_should_not_have_a_different_user!
        raise AlreadyInitialised, "current_user different" if data_store.current_user.present? && data_store.current_user != current_user
      end

      def data_store_should_not_have_a_different_school!
        raise AlreadyInitialised, "school different" if data_store.school_id.present? && data_store.school_id != school.slug
      end

      def adding_ect_as_mentor?
        participant_type == "mentor" && !@email_owner&.teacher_profile&.participant_profiles&.mentors&.exists?
      end
    end
  end
end
