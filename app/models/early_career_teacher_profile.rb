# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school
  has_one :core_induction_programme
  belongs_to :cohort, optional: true
end
