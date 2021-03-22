# frozen_string_literal: true

# == Schema Information
#
# Table name: cohorts
#
#  id         :uuid             not null, primary key
#  start_year :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Cohort < ApplicationRecord
  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user

  def display_name
    start_year.to_s
  end
end
