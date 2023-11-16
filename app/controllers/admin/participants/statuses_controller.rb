# frozen_string_literal: true

module Admin::Participants
  class StatusesController < Admin::BaseController
    include RetrieveProfile

    def show
      appropriate_body_induction_record = Induction::FindBy.call(participant_profile: @participant_profile, appropriate_body: @participant_profile.school_cohort&.appropriate_body)
      @appropriate_body_training_record_states = DetermineTrainingRecordState.call(induction_records: appropriate_body_induction_record)

      delivery_partner_induction_record = Induction::FindBy.call(participant_profile: @participant_profile, delivery_partner: @participant_profile.school_cohort&.delivery_partner)
      @delivery_partner_training_record_states = DetermineTrainingRecordState.call(induction_records: delivery_partner_induction_record)

      @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end

  private

    # Get the school from the induction record for ECTs and from the participant profile for NPQs
    def school
      @school ||= @participant_profile.latest_induction_record&.school || @participant_profile.school
    end
  end
end
