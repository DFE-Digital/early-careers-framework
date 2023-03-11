# frozen_string_literal: true

module Admin
  module NPQ
    class NotesController < Admin::BaseController
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def edit; end

      def update
        @application.assign_attributes(note_params)

        if @application.save
          redirect_to admin_npq_applications_edge_case(@application)
        else
          render action: "edit"
        end
      end

    private

      def note_params
        params.require(:npq_application).permit(:notes)
      end
    end
  end
end
