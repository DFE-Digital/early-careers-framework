# frozen_string_literal: true

module RecordDeclarations
  module EarlyCareerTeacher
    extend ActiveSupport::Concern

    included do
      include ECF
      delegate :early_career_teacher_profile, to: :user
    end

    def user_profile
      early_career_teacher_profile
    end
  end
end
