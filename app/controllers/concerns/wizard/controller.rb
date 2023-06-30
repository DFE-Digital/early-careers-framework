# frozen_string_literal: true

module Wizard
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :wizard_back_link_path
    end

    def show
      wizard.before_render

      render wizard.view_name

      wizard.after_render
    end

    def update
      if wizard.form.valid?
        wizard.save!
        redirect_to wizard.next_step_path
      else
        render wizard.current_step
      end
    end

    def initialize_wizard
      if request.get? || request.head?
        wizard.changing_answer(params["changing_answer"] == "1")
        wizard.validate_state!
        wizard.update_history
      else
        wizard.validate_state!
      end
    rescue Wizard::Form::AlreadyInitialised, Wizard::Form::InvalidStep
      remove_session_data
      redirect_to abort_path
    end

    def wizard_back_link_path
      wizard.previous_step_path
    end

    def step_name
      params[:step]&.underscore || default_step_name
    end

    def submitted_params
      params.fetch(wizard_class.session_key, {}).permit(wizard_class.permitted_params_for(step_name))
    end

    def remove_session_data
      session.delete(wizard_class.session_key)
    end
  end
end
