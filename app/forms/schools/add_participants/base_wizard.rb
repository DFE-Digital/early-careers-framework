# frozen_string_literal: true

module Schools
  module AddParticipants
    class BaseWizard
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      class AlreadyInitialised < StandardError; end

      class InvalidStep < StandardError; end

      attr_reader :current_step, :submitted_params, :data_store, :current_user, :participant_profile

      FIRST_ACADEMIC_DATE_2021 = Date.new(2021, 9, 1)

      delegate :before_render, to: :form
      delegate :view_name, to: :form
      delegate :after_render, to: :form

      delegate :return_point, :changing_answer?, :transfer?, :participant_type, :trn, :confirmed_trn, :date_of_birth,
               :induction_start_date, :nino, :ect_participant?, :mentor_id, :continue_current_programme?, :participant_profile,
               :sit_mentor?, :mentor_participant?, :appropriate_body_confirmed?, :appropriate_body_id, :known_by_another_name?,
               :same_provider?, :was_withdrawn_participant?, :complete?, :start_date, :start_term, :last_visited_step,
               :full_name, to: :data_store

      def initialize(current_step:, data_store:, current_user:, school_cohort: nil, school: nil, submitted_params: {})
        @current_user = current_user
        @data_store = data_store
        @school = school
        @school_cohort = school_cohort
        @submitted_params = submitted_params
        @participant_profile = nil
        @email_owner = nil
        @return_point = nil
        @previous_step = nil

        set_current_step(current_step)

        check_data_store_state!
        data_store_should_not_have_a_different_user!
        if FeatureFlag.active?(:cohortless_dashboard)
          data_store_should_not_have_a_different_school!
        else
          data_store_should_not_have_a_different_school_cohort!
        end

        load_current_user_and_school_into_data_store
      end

      def self.permitted_params_for(step)
        "Schools::AddParticipants::WizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
      end

      def abort_path
        school_participants_path(school_id: school.slug)
      end

      def dashboard_path
        if FeatureFlag.active?(:cohortless_dashboard)
          school_participants_path(school_id: school.slug)
        else
          schools_participants_path(school_id: school.slug, cohort_id: school_cohort.cohort.start_year)
        end
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

      def join_school_programme?
        withdrawn_participant? || data_store.join_school_programme?
      end

      def not_known_by_another_name?
        # only true if responded to question with no
        data_store.get(:known_by_another_name) == "no"
      end

      def school
        return @school if FeatureFlag.active?(:cohortless_dashboard)

        @school ||= school_cohort.school
      end

      def school_cohort
        if FeatureFlag.active?(:cohortless_dashboard)
          # determine this based on which cohort to place the participant in
          @school_cohort ||= school.school_cohorts.find_by(cohort: participant_cohort)
        else
          @school_cohort
        end
      end

      def lead_provider
        @lead_provider ||= school_cohort.default_induction_programme&.lead_provider
      end

      def delivery_partner
        @delivery_partner ||= school_cohort.default_induction_programme&.delivery_partner
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
        @existing_participant_profile ||= ParticipantProfile::ECF
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
        ect_participant? && school_cohort&.appropriate_body&.present?
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
        trn.present? && date_of_birth.present?
      end

      def found_participant_in_dqt?
        check_for_dqt_record? && dqt_validation.valid?
      end

      def dqt_record?
        check_for_dqt_record? && dqt_validation(force_recheck: true).valid?(skip_name_validation: true)
      end

      def dqt_validation(force_recheck: false)
        @dqt_validation = nil if force_recheck

        @dqt_validation ||= ParticipantValidation.new(full_name:,
                                                      trn: formatted_trn,
                                                      date_of_birth:,
                                                      nino: formatted_nino).tap do |validation|
          set_confirmed_trn_and_induction_start_date(validation)
        end
      end

      def set_confirmed_trn_and_induction_start_date(validation)
        if validation.valid?(skip_name_validation: true)
          data_store.set(:confirmed_trn, TeacherReferenceNumber.new(validation.trn).formatted_trn)
          data_store.set(:induction_start_date, validation.induction_start_date)
        else
          data_store.set(:confirmed_trn, nil)
          data_store.set(:induction_start_date, nil)
        end
      end

      def participant_cohort
        @participant_cohort ||= cohort_to_place_participant
      end

      # NOTE: not preventing registration here just determining where to put the participant
      def cohort_to_place_participant
        if transfer?
          existing_participant_cohort || existing_participant_profile&.schedule&.cohort
        elsif induction_start_date.present?
          Cohort.containing_date(date: [induction_start_date, FIRST_ACADEMIC_DATE_2021].max)
        elsif Cohort.current == Cohort.active_registration_cohort
          # true from 1/9 to next cohort registration start date
          Cohort.current
        elsif start_term == "summer"
          # we're in the registration window prior to 1/9
          Cohort.current
        else
          # we're in the registration window prior to 1/9 and chose autumn or spring the following year
          Cohort.next
        end
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
        if FeatureFlag.active?(:cohortless_dashboard)
          data_store.set(:school_id, school.slug)
        else
          data_store.set(:school_cohort_id, school_cohort.id)
        end
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

        path_opts[:cohort_id] = school_cohort.cohort.start_year unless FeatureFlag.active?(:cohortless_dashboard)
        path_opts[:step] = step.to_s.dasherize if step.present?
        path_opts
      end

      def reset_form
        %i[
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
        ].each do |key|
          data_store.set(key, nil)
        end
        data_store.set(:full_name, current_user.full_name) if current_step == :yourself

        load_current_user_and_school_into_data_store
      end

      # sanity checks
      def check_data_store_state!
        if current_step.in? %i[participant_type yourself]
          reset_form if submitted_params.empty?
        elsif data_store.store.empty?
          raise InvalidStep, "Datastore is empty at [#{step}]"
        end
      end

      def data_store_should_not_have_a_different_user!
        raise AlreadyInitialised, "current_user different" if data_store.current_user.present? && data_store.current_user != current_user
      end

      def data_store_should_not_have_a_different_school!
        raise AlreadyInitialised, "school different" if data_store.school_id.present? && data_store.school_id != school.slug
      end

      def data_store_should_not_have_a_different_school_cohort!
        raise AlreadyInitialised, "school_cohort different" if data_store.school_cohort_id.present? && data_store.school_cohort_id != school_cohort.id
      end
    end
  end
end
