# frozen_string_literal: true

module Admin::Participants
  class StatusesController < Admin::BaseController
    include RetrieveProfile

    def show
      appropriate_body_induction_record = Induction::FindBy.call(participant_profile: @participant_profile, appropriate_body: @participant_profile.school_cohort&.appropriate_body)
      @appropriate_body_training_record_states = DetermineTrainingRecordState.call(participant_profiles: @participant_profile, induction_records: appropriate_body_induction_record)
      @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end

  private

    def school
      @school ||= @participant_profile.school
    end
  end
end
