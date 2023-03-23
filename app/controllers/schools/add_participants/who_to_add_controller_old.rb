# frozen_string_literal: true

module Schools
  module AddParticipants
    class WhoToAddController < ::Schools::BaseController
      before_action :set_school_cohort
      before_action :set_form

      def new; end

      def create
        @form.assign_attributes(submitted_params)
        if @form.valid?
          if @form.ect_chosen?
            redirect_to start_schools_add_ect_participants_path(cohort_id: @school_cohort.cohort.start_year)
          else
            redirect_to start_schools_add_mentor_participants_path(cohort_id: @school_cohort.cohort.start_year)
          end
        else
          render :new
        end
      end

    private

      def set_form
        @form = WhoToAddForm.new
      end

      def submitted_params
        params.fetch(:who_to_add_form, {}).permit(:participant_type)
      end
    end
  end
end
