# frozen_string_literal: true

module Schools
  class AddParticipantsController < ::Schools::BaseController
    include Multistep::Controller

    skip_after_action :verify_authorized
    before_action :set_school_cohort

    form AddParticipantForm, as: :add_participant_form
    result as: :participant_profile

    def start
      reset_form

      if type_param
        add_participant_form.assign_attributes(type: type_param)
        store_form_in_session

        if add_participant_form.type == :self
          redirect_to action: :show, step: :yourself
        else
          redirect_to action: :show, step: :started
        end
      end
    end

    def who
      reset_form
      @who_to_add_form = build_participant_type_form
    end

    def chosen_who_to_add
      @who_to_add_form = build_participant_type_form

      unless @who_to_add_form.valid?
        render "schools/add_participants/who" and return
      end

      if @who_to_add_form.type == "transfer"
        redirect_to what_we_need_schools_transferring_participant_path(cohort_id: school_cohort.cohort.start_year)
      else
        add_participant_form.assign_attributes(type: @who_to_add_form.type)
        store_form_in_session
        redirect_to action: :show, step: :name
      end
    end

    abandon_journey_path do
      school_cohort.active_ecf_participants.any? ? schools_participants_path : schools_cohort_path
    end

    setup_form do |form|
      form.school_cohort_id = @school_cohort.id
      form.current_user_id = current_user.id
    end

  private

    def type_param
      params[:type]&.to_sym
    end

    def build_participant_type_form
      Schools::NewParticipantOrTransferForm.new(who_to_add_params)
    end

    def who_to_add_params
      return {} unless params.key?(:schools_new_participant_or_transfer_form)

      params.require(:schools_new_participant_or_transfer_form).permit(:type)
    end

    def email_used_in_the_same_school?
      Identity.find_user_by(email: add_participant_form.email).school == add_participant_form.school_cohort.school
    end

    helper_method :email_used_in_the_same_school?

    def school_cohort
      return @school_cohort if defined?(@school_cohort)

      set_school_cohort
      @school_cohort
    end
  end
end
