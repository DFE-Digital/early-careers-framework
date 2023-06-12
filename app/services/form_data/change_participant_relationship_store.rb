# frozen_string_literal: true

module FormData
  class ChangeParticipantRelationshipStore < DataStore
    def to_s
      values = []
      store.map { |k, v| values << "#{k}->#{v}" }.join("\n")
    end

    def current_user
      get :current_user
    end

    def return_point
      get(:return_point) || ""
    end

    def changing_answer?
      get(:changing_answer) == true
    end

    def participant_profile
      get(:participant_profile)
    end

    def complete?
      get(:complete) == true
    end

    def last_visited_step
      get(:last_visited_step)
    end

    def history_stack
      get(:history_stack) || []
    end
  end
end
