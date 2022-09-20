# frozen_string_literal: true

module Admin::Participants
  class ChangeInductionStartDateController < Admin::BaseController
    def edit
      @participant_profile = retrieve_participant_profile
      @participant_profile_form = ChangeInductionStartDateForm.new(
        induction_start_date: @participant_profile.induction_start_date,
      )
    end

    def update
      @participant_profile = retrieve_participant_profile
      @participant_profile_form = ChangeInductionStartDateForm.new(change_induction_start_date_params)

      if @participant_profile_form.valid?
        induction_start_date = @participant_profile_form.induction_start_date
        ChangeInductionStartDate.call(@participant_profile, induction_start_date:)

        redirect_to(admin_participant_path(@participant_profile))
      else
        render(:edit)
      end
    end

  private

    def retrieve_participant_profile
      policy_scope(ParticipantProfile).find(params[:participant_id]).tap do |participant_profile|
        authorize participant_profile, policy_class: participant_profile.policy_class
      end
    end

    def change_induction_start_date_params
      params.require(:admin_participants_change_induction_start_date_form).permit(:induction_start_date)
    end
  end
end
