# frozen_string_literal: true

module Admin
  class NotesController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :load_participant

    def edit; end

    def update
      @participant_profile.assign_attributes(note_params)

      if @participant_profile.save
        redirect_to admin_participant_path(@participant_profile)
      else
        render action: "edit"
      end
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile.find(params[:id])
      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end

    def note_params
      params.require(:participant_profile).permit(:notes)
    end
  end
end
