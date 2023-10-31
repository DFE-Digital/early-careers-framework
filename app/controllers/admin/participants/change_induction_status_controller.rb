# frozen_string_literal: true

module Admin::Participants
  class ChangeInductionStatusController < Admin::BaseController
    before_action :retrieve_participant_profile

    def edit; end

    def confirm_induction_status
      @participant_profile = retrieve_participant_profile
      @relevant_induction_record = Induction::FindBy.new(participant_profile: @participant_profile).call

      update_the_participant_profile unless @participant_profile.active_record?
      update_the_induction_record if %w[withdrawn leaving].include?(@relevant_induction_record&.induction_status)

      flash[:success] = {
        title: "Induction status changed successfully",
        content: "#{@participant_profile.user.full_name}'s induction status was changed to active",
      }

      redirect_to(admin_participant_statuses_path(@participant_profile))
    end

  private

    def retrieve_participant_profile
      @participant_profile =
        policy_scope(ParticipantProfile).find(params[:participant_id]).tap do |participant_profile|
          authorize participant_profile, policy_class: participant_profile.policy_class
        end
    end

    def update_the_participant_profile
      @participant_profile.update(status: :active)
    end

    def update_the_induction_record
      induction_record_changes = { induction_status: :active }
      induction_record_changes[:school_transfer] = true if @relevant_induction_record&.leaving_induction_status?

      Induction::ChangeInductionRecord.call(
        induction_record: @relevant_induction_record,
        changes: induction_record_changes,
      )
    end
  end
end
