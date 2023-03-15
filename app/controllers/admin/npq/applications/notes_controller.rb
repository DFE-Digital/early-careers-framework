# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class NotesController < Admin::BaseController
        skip_after_action :verify_authorized
        skip_after_action :verify_policy_scoped

        def edit
          @npq_application = NPQApplication.find(params[:id])
        end

        def update
          npq_application = NPQApplication.find(params[:id])
          npq_application.assign_attributes(note_params)

          if npq_application.save
            name = npq_application.participant_identity.user.full_name

            flash[:success] = {
              title: "#{name} updated",
              content: "#{name} has a new note: '#{npq_application.notes.humanize.downcase}' ",
            }
            redirect_to admin_npq_applications_edge_case_path(npq_application)
          else
            flash[:alert] = {
              title: "#{name} not updated",
              content: "#{name} failed to update",
            }
            render(:edit)
          end
        end

      private

        def note_params
          params.require(:npq_application).permit(:notes)
        end
      end
    end
  end
end
