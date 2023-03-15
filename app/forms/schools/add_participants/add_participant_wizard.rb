# frozen_string_literal: true

module Schools
  class AddParticipantWizard
    include ActiveModel::Model
    include Rails.application.routes.url_helpers

    class InvalidStep < StandardError; end

    attr_reader :current_step, :submitted_params, :current_state, :current_user, :school_cohort

    delegate :before_render, to: :form
    delegate :after_render, to: :form

    def initialize(current_step:, current_state:, current_user:, school_cohort:, submitted_params: {})
      set_current_step(current_step)

      @current_user = current_user
      @current_state = current_state
      @school_cohort = school_cohort
      @submitted_params = submitted_params

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

    def save!
      save_progress!

      if form.journey_complete?
        add_participant!
      end
    end

    def next_step_path
      if changing_answer?
        if dqt_record(force_recheck: true).present?
          if email.present?
            "check-answers"
          else
            "email"
          end
        else
          "cannot-find-their-details"
        end
      else
        form.next_step.to_s.dasherize
      end
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

    def form_for_step(step)
      step_form_class = form_class_for(step)
      hash = current_state.slice(*step_form_class.permitted_params.map(&:to_s))
      hash.merge!(wizard: self)
      step_form_class.new(hash)
    end

    def possessive_name
      if sit_mentor?
        "your"
      else
        # FIXME: do something better here
        ApplicationController.helpers.possessive_name(full_name)
      end
    end

    def full_name
      if sit_mentor?
        current_user.full_name
      else
        current_state["full_name"]
      end
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
      if sit_mentor?
        current_user.email
      else
        current_state["email"]
      end
    end

    def nino
      current_state["nino"]
    end

    def ect_participant?
      current_state["participant_type"] == "ect"
    end

    def sit_mentor?
      current_state["participant_type"] == "self"
    end

    def found_participant_in_dqt?
      check_for_dqt_record? && dqt_record.present?
    end

    def participant_exists?
      check_for_dqt_record? && dqt_record.present? && TeacherProfile.joins(:ecf_profiles).where(trn: formatted_trn).any?
    end

    def needs_to_choose_a_mentor?
      ect_participant? && mentor_id.blank? && mentor_options.any?
    end

    def mentor_options
      @mentor_options ||= school_cohort.school.mentors
    end

    def mentor
      @mentor ||= (User.find(mentor_id) if mentor_id && mentor_id != "later")
    end

    def mentor_id
      current_state["mentor_id"]
    end

    def mentor_profile_id
      mentor&.mentor_profile&.id
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
      current_state["participant_type"] = nil
      current_state["full_name"] = nil
      current_state["trn"] = nil
      current_state["date_of_birth"] = nil
      current_state["nino"] = nil
      current_state["email"] = nil
      current_state["mentor_id"] = nil
      current_state["start_date"] = nil
      current_state["appropriate_body_id"] = nil
      current_state["appropriate_body_confirmed"] = nil
    end

  private

    def save_progress!
      form.before_save

      form.attributes.each do |k, v|
        current_state[k.to_s] = v
      end

      form.after_save
    end

    def add_participant!
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
        mentor_profile_id:,
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
      "#{self.class.name}Steps::#{step.to_s.camelcase}Step".constantize
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
        email
        start_date
        choose_mentor
        confirm_appropriate_body
        check_answers
        confirmation
      ]
    end
  end
end
