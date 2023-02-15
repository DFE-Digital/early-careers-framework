# frozen_string_literal: true

module Admin::Participants
  class EventHistoryController < Admin::BaseController
    include RetrieveProfile

    def show
      @user = @participant_profile.user
      @event_list = Participants::HistoryBuilder.from_participant_profile(@participant_profile).events
    end
  end
end
