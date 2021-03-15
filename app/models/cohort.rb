# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user

  def display_name
    start_year.to_s
  end
end
