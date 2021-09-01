# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class NPQ < Base
      include Participants::NPQ
      include ScheduleValidation

      def perform_action!
        user_profile.update_schedule!(schedule)
        user_profile
      end

    end
  end
end
