# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true

  has_many :course_lesson_progresses
  has_many :course_lessons, through: :course_lesson_progresses
end
