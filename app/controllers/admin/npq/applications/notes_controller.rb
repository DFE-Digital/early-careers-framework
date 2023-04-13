# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class NotesController < Admin::BaseController
        skip_after_action :verify_policy_scoped

        before_action :assign_npq_application

        def edit; end

        def update
          @npq_application = NPQApplication.find(params[:id])
          @npq_application.assign_attributes(note_params)

          name = @npq_application.participant_identity.user.full_name
          if @npq_application.save

            flash[:success] = {
              title: "#{name} updated",
              content: "#{name} has a new note, see below for details.",
            }

            redirect_to admin_npq_applications_edge_case_path(@npq_application)
          else
            flash[:alert] = "Note failed to be saved"
            render :edit,
                   status: :bad_request
          end
        end

      private

        def assign_npq_application
          authorize NPQApplication

          @npq_application = NPQApplication.find(params[:id])
        end

        def note_params
          params.require(:npq_application).permit(:notes)
        end
      end
    end
  end
end
