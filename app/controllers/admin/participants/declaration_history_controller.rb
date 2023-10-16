# frozen_string_literal: true

module Admin::Participants
  class DeclarationHistoryController < Admin::BaseController
    include RetrieveProfile

    def show
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
