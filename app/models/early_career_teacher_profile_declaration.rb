# frozen_string_literal: true

class EarlyCareerTeacherProfileDeclaration < ApplicationRecord
  belongs_to :early_career_teacher_profile

  scope :unique_id, -> { select(:early_career_teacher_profile_id).distinct }
  scope :uplift, -> { joins(:early_career_teacher_profile).merge(EarlyCareerTeacherProfile.uplift) }
end
