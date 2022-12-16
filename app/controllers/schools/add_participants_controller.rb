# frozen_string_literal: true

module Schools
  class AddParticipantsController < ::Schools::BaseController
    include Multistep::Controller
    include AppropriateBodySelection::Controller

    skip_after_action :verify_authorized
    before_action :set_school_cohort
    before_action :ensure_form_present, except: %i[start who participant_type]

    form AddParticipantForm, as: :add_participant_form
    result as: :participant_profile

    def cannot_add_mentor_without_trn; end

    def start
      reset_form

      if type_param
        add_participant_form.assign_attributes(type: type_param)
        store_form_in_session
        case add_participant_form.type
        when :self
          redirect_to action: :show, step: :yourself
        else
          redirect_to action: :show, step: :name
        end
      end
    end

    def who
      @who_to_add_form = build_participant_type_form(type: add_participant_form.type)
      reset_form
    end

    def participant_type
      @who_to_add_form = build_participant_type_form
      unless @who_to_add_form.valid?
        render "schools/add_participants/who" and return
      end

      redirect_to what_we_need_schools_transferring_participant_path(cohort_id: school_cohort.cohort.start_year) and return if selected_transfer_journey?

      add_participant_form.assign_attributes(type: @who_to_add_form.type)
      store_form_in_session

      redirect_to action: :what_we_need
    end

    def what_we_need; end

    def transfer
      render(current_step) && return unless form.complete_step(:transfer, form_params)
      render(form.next_step) && return unless form.transfer?

      session[:schools_transferring_participant_form] = form.serializable_hash(only: %i[full_name trn date_of_birth])
      remove_form
      render(:target_school_cohort_not_set) && return unless target_school_cohort_set?

      redirect_to teacher_start_date_schools_transferring_participant_path(cohort_id: target_cohort_start_year)
    end

    def change_appropriate_body
      add_participant_form.appropriate_body_confirmed = false
      add_participant_form.complete_step(:confirm_appropriate_body)
      store_form_in_session
      start_appropriate_body_selection
    end

    abandon_journey_path do
      school_cohort.active_ecf_participants.any? ? schools_participants_path : schools_cohort_path
    end

    setup_form do |form|
      form.school_cohort_id = @school_cohort.id
      form.current_user_id = current_user.id
    end

  private

    def build_participant_type_form(**defaults)
      Schools::NewParticipantOrTransferForm.new(defaults.merge(who_to_add_params))
    end

    def email_used_in_the_same_school?
      Identity.find_user_by(email: add_participant_form.email).school == add_participant_form.school_cohort.school
    end

    helper_method :email_used_in_the_same_school?

    def in_current_active_cohort?
      school_cohort.cohort == Cohort.active_registration_cohort
    end

    def new_school_participant_cohort
      @school.school_cohorts.detect do |school_cohort|
        school_cohort.start_year == participant_profile.cohort_start_year
      end
    end

    def participant_profile
      @participant_profile ||= form.check_for_existing_profile
    end

    def redirect_to_next_step
      redirect_to action: :show, step: step_param(form.next_step)
    end

    def save_appropriate_body
      add_participant_form.assign_attributes({
        appropriate_body_confirmed: false,
        appropriate_body_id: @appropriate_body_form.body_id,
      })
      store_form_in_session
      redirect_to_next_step
    end

    def school_cohort
      return @school_cohort if defined?(@school_cohort)

      set_school_cohort
      @school_cohort
    end

    def selected_transfer_journey?
      @who_to_add_form.type == "transfer"
    end

    def start_appropriate_body_selection
      super from_path: url_for(action: :show, step: "confirm-appropriate-body"),
            submit_action: :save_appropriate_body,
            school_name: @school.name,
            ask_appointed: false
    end

    def target_cohort_start_year
      @target_cohort_start_year ||= target_school_cohort&.start_year || participant_profile.cohort_start_year
    end

    def target_cohort
      target_school_cohort.cohort
    end

    def target_school_cohort
      @target_school_cohort ||= transferable_to_cohort_chosen? ? school_cohort : new_school_participant_cohort
    end

    def target_school_cohort_set?
      [target_cohort_start_year, target_school_cohort].all?(&:present?)
    end

    def transferable_to_cohort_chosen?
      @transferable_to_cohort_chosen ||= Schools::ParticipantTransferableToSchoolForm.new(
        participant_profile:,
        school: @school,
        start_year: school_cohort.start_year,
      ).valid?
    end

    def type_param
      params[:type]&.to_sym
    end

    def who_to_add_params
      return {} unless params.key?(:schools_new_participant_or_transfer_form)

      params.require(:schools_new_participant_or_transfer_form).permit(:type).to_h.symbolize_keys
    end
  end
end
