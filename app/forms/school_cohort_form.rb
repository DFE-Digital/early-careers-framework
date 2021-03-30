# frozen_string_literal: true

class SchoolCohortForm
  include ActiveModel::Model

  attr_accessor :estimated_mentor_count, :estimated_teacher_count

  validates :estimated_mentor_count, presence: { message: "Enter your expected number of mentors" }
  validates :estimated_teacher_count, presence: { message: "Enter your expected number of ECTs" }
  validates :estimated_mentor_count, numericality: { greater_than_or_equal_to: 0, less_than: 1000 }
  validates :estimated_teacher_count, numericality: { greater_than_or_equal_to: 0, less_than: 1000 }
end
