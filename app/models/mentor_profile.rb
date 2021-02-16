# frozen_string_literal: true

class MentorProfile < ApplicationRecord
  belongs_to :user
  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user
end
