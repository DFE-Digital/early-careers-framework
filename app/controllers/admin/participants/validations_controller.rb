# frozen_string_literal: true

module Admin
  module Participants
    class ValidationsController < BaseController
      skip_after_action :verify_policy_scoped
      before_action :load_decision

      def show; end

      def update
        if @decision.update(decision_params)
          set_success_message(
            heading: "Participant task '#{t(:name, scope: t_scope)}' has been #{@decision.approved? ? 'approved' : 'rejected'}",
          )
          redirect_to admin_participant_path(@participant_profile)
        else
          render :show
        end
      end

    private

      def load_decision
        @participant_profile = ParticipantProfile.find(params[:id])
        authorize @participant_profile, :validate?, policy_class: ParticipantProfilePolicy

        @decision = @participant_profile.validation_decision(params[:step])
      end

      def t_scope
        "schools.participants.validations.#{@participant_profile.participant_type}.#{params[:step]}"
      end
      helper_method :t_scope

      def decision_params
        params.require(:profile_validation_decision).permit(:approved, :note)
      end
    end
  end
end
