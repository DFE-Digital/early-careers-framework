# frozen_string_literal: true

module Admin::Participants
  class ChangeEmailController < Admin::BaseController
    before_action :load_participant
    skip_after_action :verify_policy_scoped

    def edit; end

    def update
      user = @participant_profile.user
      user.assign_attributes(params.require(:user).permit(:email))

      if user.save
        if @participant_profile.ect?
          set_success_message(heading: "The ECT’s email address has been updated")
        else
          set_success_message(heading: "The mentor’s email address has been updated")
        end
        redirect_to admin_participants_path
      else
        render "admin/participants/change_email/edit"
      end
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile
                               .eager_load(:teacher_profile, :ecf_participant_validation_data).find(params[:participant_id])

      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end
  end
end
