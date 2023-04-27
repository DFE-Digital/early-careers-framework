# frozen_string_literal: true

module Admin::NPQ::Applications
  class ChangeEmailController < Admin::BaseController
    before_action :load_npq_application
    before_action :check_gai_status

    skip_after_action :verify_policy_scoped

    def edit; end

    def update
      user = @npq_application.user
      user.assign_attributes(params.require(:user).permit(:email))

      if user.save
        set_success_message(heading: "The user’s email address has been updated")
        redirect_to admin_npq_applications_application_path
      else
        render "/admin/npq/applications/change_email/edit"
      end
    end

  private

    def check_gai_status
      redirect_to admin_npq_applications_application_path if @npq_application.user.get_an_identity_id.present?
    end

    def load_npq_application
      authorize NPQApplication

      @npq_application = NPQApplication
        .eager_load(:profile, participant_identity: :user)
        .find(params[:id])
    end
  end
end
