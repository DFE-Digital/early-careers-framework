# frozen_string_literal: true

require "./app/wizards/schools/change_lead_provider/base_wizard"

module Schools
  class ChangeLeadProviderController < ::Schools::BaseController
    before_action :set_school
    before_action :initialize_wizard

    def new
      render current_step
    end

    def create
      if @wizard.valid_step?
        @wizard.save!

        redirect_to @wizard.next_step_path
      else
        render current_step
      end
    end

    def intro
      if params[:participant_id].present?
        render :participant_intro
      else
        render :academic_year_intro
      end
    end

  private

    def initialize_wizard
      @wizard = wizard_class.new(
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
      @store ||= FormData::ChangeLeadProviderStore.new(session:, form_key:)
    end

    def form_key
      participant_change_request? ? :change_lead_provider_for_participant : :change_lead_provider_for_year
    end

    def current_step
      step_from_path = request.path.split("/").last.underscore.to_sym
      return :not_found if wizard_class.steps.first.keys.exclude?(step_from_path)

      step_from_path
    end

    def step_params
      return default_params if params[current_step].blank?

      params
    end

    def default_params
      ActionController::Parameters.new({ current_step => params })
    end

    def participant_id
      return unless participant_change_request?

      @participant_id ||= participant.id
    end

    def participant
      @participant ||= ParticipantProfile.find(params[:participant_id])
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
      path_params = { school_id:, start_year: }
      participant_change_request? ? path_params.merge(participant_id:) : path_params
    end
    helper_method :default_path_params

    def academic_year
      @academic_year ||= "#{start_year} to #{start_year.to_i + 1}"
    end
    helper_method :academic_year

    def participant_change_request?
      params[:participant_id].present?
    end

    def wizard_class
      Schools::ChangeLeadProvider::BaseWizard
    end
  end
end
