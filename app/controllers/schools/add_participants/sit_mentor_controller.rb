# frozen_string_literal: true

module Schools
  module AddParticipants
    class SitMentorController < WhoToAddController
    private

      def default_form_step
        "yourself"
      end
    end
  end
end
