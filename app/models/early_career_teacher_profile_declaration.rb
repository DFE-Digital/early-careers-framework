# frozen_string_literal: true

class EarlyCareerTeacherProfileDeclaration < ApplicationRecord
  belongs_to :early_career_teacher_profile
  include Declarable

  scope :uplift, -> { joins(:early_career_teacher_profile).merge(EarlyCareerTeacherProfile.uplift) }
end
