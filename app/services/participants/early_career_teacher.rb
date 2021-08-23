# frozen_string_literal: true

module Participants
  module EarlyCareerTeacher
    include ECF
    extend ActiveSupport::Concern
    included do
      extend EarlyCareerTeacherClassMethods
      delegate :early_career_teacher_profile, to: :user, allow_nil: true
    end

    def user_profile
      early_career_teacher_profile
    end

    module EarlyCareerTeacherClassMethods
      def valid_courses_for_user
        %w[ecf-induction]
      end
    end
  end
end
