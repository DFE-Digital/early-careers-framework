# frozen_string_literal: true

require "./app/wizards/schools/early_career_teachers/change_lead_provider/base_wizard"

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class BaseController < ::Schools::EarlyCareerTeachersController
        def new
          @wizard = BaseWizard.new(
            current_step:,
            step_params:,
            participant_id:,
            school_id:,
            start_year:,
          )
        end

        def create
          @wizard = BaseWizard.new(
            current_step:,
            step_params:,
            participant_id:,
            school_id:,
            start_year:,
          )

          if @wizard.valid_step?
            redirect_to @wizard.next_step_path
          else
            render :new
          end
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

        def participant
          @participant ||= ParticipantProfile::ECT.find(params[:participant_id])
        end
      end
    end
  end
end
