# frozen_string_literal: true

module Schools
  module AddParticipants
    class BaseController < Schools::BaseController
      before_action :set_school_cohort

      # where to look for step views
      def self.controller_path
        "schools/add_participants"
      end

      def show
        @wizard.before_render

        render @wizard.view_name

        @wizard.after_render
      end

      def update
        if @form.valid?
          @wizard.save!

          redirect_to @wizard.next_step_path
        else
          render @wizard.current_step
        end
      end

      helper_method :wizard_back_link_path

    private

      def data_check
        raise NotImplementedError
      end

      def wizard_class
        raise NotImplementedError
      end

      def default_step_name
        raise NotImplementedError
      end

      def initialize_wizard
        if request.get? || request.head?
          @wizard = wizard_class.new(current_step: step_name,
                                     data_store:,
                                     current_user:,
                                     school_cohort: @school_cohort)

          @wizard.changing_answer(params["changing_answer"] == "1")
        else
          @wizard = wizard_class.new(current_step: step_name,
                                     data_store:,
                                     current_user:,
                                     school_cohort: @school_cohort,
                                     submitted_params:)
        end
        @form = @wizard.form
      rescue BaseWizard::AlreadyInitialised, BaseWizard::InvalidStep
        remove_session_data
        redirect_to abort_path
      end

      def abort_path
        FeatureFlag.active?(:cohortless_dashboard) ? school_participants_path : schools_participants_path
      end

      def wizard_back_link_path
        @wizard.previous_step_path
      end

      def data_store
        @data_store ||= FormData::AddParticipantStore.new(session:, form_key: :add_participant_wizard)
      end

      def step_name
        params[:step]&.underscore || default_step_name
      end

      def submitted_params
        params.fetch(:add_participant_wizard, {}).permit(wizard_class.permitted_params_for(step_name))
      end

      def remove_session_data
        session.delete(:add_participant_wizard)
      end
    end
  end
end
