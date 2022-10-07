# frozen_string_literal: true

module Admin::Participants
  class ChangeCohortController < Admin::BaseController
    skip_after_action :verify_policy_scoped, except: :index
    skip_after_action :verify_authorized, only: :index

    def show
      load_participant
      set_event_list
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile
                               .eager_load(:teacher_profile).find(params[:id])

      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end

    def set_event_list
      @event_list ||= Admin::Participants::HistoryBuilder.from_profile(@participant_profile).events
    end
  end
end

