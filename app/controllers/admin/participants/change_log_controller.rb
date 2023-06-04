# frozen_string_literal: true

module Admin::Participants
  class ChangeLogController < Admin::BaseController
    include RetrieveProfile

    def show
      @event_list = Participants::HistoryBuilder.from_participant_profile(@participant_profile).events

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
