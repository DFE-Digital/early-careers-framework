# frozen_string_literal: true

module RecordDeclarations
  module EarlyCareerTeacher
    extend ActiveSupport::Concern

    included do
      include ECF
      extend EarlyCareerTeacherClassMethods
      delegate :early_career_teacher_profile, to: :user
    end

    module EarlyCareerTeacherClassMethods
      def valid_courses
        %w[ecf-induction]
      end
    end

    def user_profile
      early_career_teacher_profile
    end
  end
end
