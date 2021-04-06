# frozen_string_literal: true

class SchoolCohortForm
  include ActiveModel::Model

  attr_accessor :estimated_mentor_count, :estimated_teacher_count

  def initialize(school_cohort)
    self.estimated_teacher_count = school_cohort[:estimated_teacher_count]
    self.estimated_mentor_count = school_cohort[:estimated_mentor_count]
  end

  validates :estimated_mentor_count, presence: { message: "Enter your expected number of mentors" }
  validates :estimated_teacher_count, presence: { message: "Enter your expected number of ECTs" }
  validates :estimated_mentor_count, numericality: { greater_than_or_equal_to: 0, less_than: 1000, only_integer: true }
  validates :estimated_teacher_count, numericality: { greater_than_or_equal_to: 0, less_than: 1000, only_integer: true }
end
