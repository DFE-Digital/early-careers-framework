# frozen_string_literal: true

module Finance
  module Participants
    class ProfilesController < BaseController
      def edit
        @profile = user.participant_profiles.find(params[:id])
      end

      def update
        @profile = user.participant_profiles.find(params[:id])
        @profile.assign_attributes(profile_attributes)

        return render :edit unless @profile.save

        redirect_to finance_participant_path(user)
      end

    private

      def profile_attributes
        params.require(:profile).permit(:training_status)
      end

      def user
        @user ||= User.find(params[:participant_id])
      end
    end
  end
end
