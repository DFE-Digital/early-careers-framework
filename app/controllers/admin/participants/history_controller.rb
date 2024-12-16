# frozen_string_literal: true

module Admin::Participants
  class HistoryController < Admin::BaseController
    include RetrieveProfile

    def show
      @participant_presenter = Admin::ParticipantPresenter.new(@participant_profile)

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end
  end
end
