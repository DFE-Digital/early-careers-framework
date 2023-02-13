# frozen_string_literal: true

module Admin::Participants
  class EventHistoryController < Admin::BaseController
    include RetrieveProfile

    def show
      @user = @participant_profile.user

      events = Participants::HistoryBuilder.from_participant_profile(@participant_profile).events.sort_by(&:date).reverse
      @event_list = events
    end
  end
end
