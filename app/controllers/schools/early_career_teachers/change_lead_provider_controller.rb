# frozen_string_literal: true

require "./app/wizards/schools/early_career_teachers/change_lead_provider/base_wizard"

module Schools
  module EarlyCareerTeachers
    class ChangeLeadProviderController < ::Schools::EarlyCareerTeachersController
      before_action :initialize_wizard

      def new
        render_current_step
      end

      def create
        if @wizard.valid_step?
          @wizard.save!

          redirect_to @wizard.next_step_path
        else
          render_current_step
        end
      end

      def initialize_wizard
        @wizard = Schools::EarlyCareerTeachers::ChangeLeadProvider::BaseWizard.new(
          current_step:,
          step_params:,
          current_user:,
          participant_id:,
          school_id:,
          start_year:,
          store:,
        )
      end

      def store
        @store ||= FormData::ChangeLeadProviderStore.new(
          session:,
          form_key: :change_lead_provider_for_participant,
        )
      end

      def render_current_step
        valid_steps.include?(current_step) ? render(current_step) : render(:not_found)
      end

      def current_step
        request.path.split("/").last.underscore.to_sym
      end

      def valid_steps
        @valid_steps ||= @wizard.steps.map(&:keys).flatten
      end

      def step_params
        return default_params if params[current_step].blank?

        params
      end

      def default_params
        ActionController::Parameters.new({ current_step => params })
      end

      def participant_id
        @participant_id ||= participant.id
      end

      def school_id
        @school_id ||= @school.id
      end

      def start_year
        @start_year ||= params[:start_year]
      end

      def lead_providers
        @lead_providers ||= LeadProvider.all.order(:name)
      end
      helper_method :lead_providers

      def default_path_params
        { school_id:, participant_id:, start_year: }
      end
      helper_method :default_path_params

      def participant
        @participant ||= ParticipantProfile.find(params[:participant_id])
      end
    end
  end
end
