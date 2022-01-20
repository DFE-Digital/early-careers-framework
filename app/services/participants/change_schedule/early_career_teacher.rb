# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class EarlyCareerTeacher < ECF
      def self.valid_courses
        %w[ecf-induction]
      end

    private

      def user_profile
        user&.early_career_teacher_profile
      end
    end
  end
end
