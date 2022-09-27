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
      induction_start_date = @participant_profile_form.induction_start_date

      if @participant_profile_form.valid? && ChangeInductionStartDate.call(@participant_profile, induction_start_date:)
        flash[:success] = {
          title: "Induction start date changed successfully",
          content: "#{@participant_profile.user.full_name}'s induction start date was changed to #{induction_start_date.to_formatted_s(:govuk)}",
        }

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
