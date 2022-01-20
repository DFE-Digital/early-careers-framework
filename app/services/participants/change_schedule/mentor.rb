# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class Mentor < ECF
      def self.valid_courses
        %w[ecf-mentor]
      end

    private

      def user_profile
        user&.mentor_profile
      end
    end
  end
end
