# frozen_string_literal: true

module RecordDeclarations
  module EarlyCareerTeacher
    extend ActiveSupport::Concern

    included do
      extend EarlyCareerTeacherClassMethods
      include ECF
      delegate :early_career_teacher_profile, to: :user
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
