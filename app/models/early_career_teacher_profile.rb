# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true
  belongs_to :mentor_profile, optional: true
  has_one  :mentor, through: :mentor_profile, source: :user

  has_many :course_lesson_progresses
  has_many :course_lessons, through: :course_lesson_progresses
end
