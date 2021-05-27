# frozen_string_literal: true

class MentorProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true
  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user
  # TODO: Add a link to participant_record if we need to
end
