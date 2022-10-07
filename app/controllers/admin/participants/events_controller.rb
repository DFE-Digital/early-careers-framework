# frozen_string_literal: true

module Admin::Participants
  class ChangeCohortController < Admin::BaseController
    def show
      load_participant
      event_list
    end

  private

    def load_participant
      @participant_profile = policy_scope(ParticipantProfile)
                               .eager_load(:teacher_profile).find(params[:id])

      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end

    def event_list
      @event_list ||= Admin::Participants::HistoryBuilder.from_profile(@participant_profile).events
    end
  end
end
