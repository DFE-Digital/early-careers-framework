# frozen_string_literal: true

module RecordDeclarations
  class ECF::EarlyCareerTeacher < ECF
    delegate :early_career_teacher_profile, to: :user

    class << self
      def valid_courses
        %w[ecf-induction]
      end
    end

    def user_profile
      early_career_teacher_profile
    end
  end
end
