# frozen_string_literal: true

module Admin::Participants
  class ChangeInductionStatusController < Admin::BaseController
    before_action :retrieve_participant_profile

    def edit; end

    def confirm_induction_status
      Induction::InductionStatusesActivator.call(participant_profile: @participant_profile)

      flash[:success] = {
        title: "Induction status changed successfully",
        content: "#{@participant_profile.user.full_name}'s induction status was changed to active",
      }

      redirect_to(admin_participant_school_path(@participant_profile))
    end

  private

    def retrieve_participant_profile
      @participant_profile =
        policy_scope(ParticipantProfile).find(params[:participant_id]).tap do |participant_profile|
          authorize participant_profile, policy_class: participant_profile.policy_class
        end
    end
  end
end
