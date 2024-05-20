# frozen_string_literal: true

module AppropriateBodySelection
  module Controller
    extend ActiveSupport::Concern

    included do
      before_action :load_appropriate_body_form,
                    :ensure_appropriate_body_data,
                    only: %i[appropriate_body_appointed
                             update_appropriate_body_appointed
                             appropriate_body
                             update_appropriate_body]

      helper_method :appropriate_body_form, :appropriate_body_from_path, :appropriate_body_school_name,
                    :appropriate_body_action_name, :preconfirm_next_action, :appropriate_body_default_selection
    end

    def appropriate_body_preconfirm
      render "/appropriate_body_selection/preconfirm"
    end

    def appropriate_body_appointed
      render "/appropriate_body_selection/body_appointed"
    end

    def update_appropriate_body_appointed
      if appropriate_body_form.valid? :body_appointed
        store_appropriate_body_form
        if appropriate_body_form.body_appointed?
          redirect_to action: :appropriate_body
        else
          submit_appropriate_body_selection
        end
      else
        track_validation_error(appropriate_body_form)
        render "/appropriate_body_selection/body_appointed"
      end
    end

    def appropriate_body
      render "/appropriate_body_selection/body_selection"
    end

    def update_appropriate_body
      if appropriate_body_form.valid? :body
        submit_appropriate_body_selection
      else
        track_validation_error(appropriate_body_form)
        render "/appropriate_body_selection/body_selection"
      end
    end

  private

    def first_action
      appropriate_body_preconfirmation ? :appropriate_body_preconfirm : preconfirm_next_action
    end

    def preconfirm_next_action
      appropriate_body_ask_appointed ? :appropriate_body_appointed : :appropriate_body
    end

    # @param [Integer] cohort_start_year When specified the appropriate bodies will be filtered to those that are active [CST-1420]
    def start_appropriate_body_selection(from_path:, submit_action:, school:, ask_appointed: true,
                                         preconfirmation: false, action_name: :add, cohort_start_year: nil)
      session.delete(:appropriate_body_selection_form)

      session[:appropriate_body_selection] = {
        action_name:,
        from_path:,
        submit_action:,
        school:,
        ask_appointed:,
        preconfirmation:,
        cohort_start_year:,
      }

      redirect_to action: first_action
    end

    def ensure_appropriate_body_data
      head :bad_request unless appropriate_body_session_data
    end

    def load_appropriate_body_form
      @appropriate_body_form = AppropriateBodySelectionForm.new(session[:appropriate_body_selection_form])
      @appropriate_body_form.cohort_start_year = appropriate_body_session_data[:cohort_start_year]
      @appropriate_body_form.assign_attributes(appropriate_body_form_params)
      set_default_appropriate_body
      @appropriate_body_form
    end

    def appropriate_body_form
      @appropriate_body_form || load_appropriate_body_form
    end

    def appropriate_body_form_params
      return {} unless params.key?(:appropriate_body_selection_form)

      params.require(:appropriate_body_selection_form)
            .permit(:body_appointed,
                    :body_id,
                    :body_type)
    end

    def store_appropriate_body_form
      session[:appropriate_body_selection_form] = appropriate_body_form.serializable_hash
    end

    def appropriate_body_session_data
      session[:appropriate_body_selection] || {}
    end

    def appropriate_body_from_path
      appropriate_body_session_data[:from_path]
    end

    def appropriate_body_submit_action
      appropriate_body_session_data[:submit_action]
    end

    def appropriate_body_ask_appointed
      appropriate_body_session_data[:ask_appointed]
    end

    def appropriate_body_action_name
      appropriate_body_session_data[:action_name]
    end

    def appropriate_body_preconfirmation
      appropriate_body_session_data[:preconfirmation]
    end

    def appropriate_body_school
      appropriate_body_session_data[:school]
    end

    def appropriate_body_school_name
      appropriate_body_session_data[:school].name
    end

    def appropriate_body_delete_session
      session.delete(:appropriate_body_selection)
    end

    def appropriate_body_default_selection
      @appropriate_body_form.default_appropriate_body
    end

    def submit_appropriate_body_selection
      store_appropriate_body_form
      method(appropriate_body_submit_action).call
      appropriate_body_delete_session
    end

    def set_default_appropriate_body
      # TODO: set default ABs
      if appropriate_body_school&.school_type_code == 37
        @appropriate_body_form.default_appropriate_body = AppropriateBody.first
      elsif appropriate_body_school&.school_type_code == 10 || appropriate_body_school&.school_type_code == 11
        @appropriate_body_form.default_appropriate_body = AppropriateBody.last
      else
        @appropriate_body_form.default_appropriate_body = nil
      end
    end
  end
end
