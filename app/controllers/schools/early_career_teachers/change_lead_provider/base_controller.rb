# frozen_string_literal: true

require "./app/wizards/schools/early_career_teachers/change_lead_provider/base_wizard"

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class BaseController < ::Schools::EarlyCareerTeachersController
        before_action :initialize_wizard

        def new; end

        def create
          if @wizard.valid_step?
            @wizard.save!

            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        def initialize_wizard
          @wizard = BaseWizard.new(
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

        def current_step
          raise NotImplementedError
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

        # TODO: Check this query is scoped correctly
        # TODO: Do we need Pundit check here?
        def participant
          @participant ||= ParticipantProfile::ECT.find(params[:participant_id])
        end
      end
    end
  end
end
