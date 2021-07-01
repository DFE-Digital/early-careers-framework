# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort
  belongs_to :mentor_profile, optional: true
  has_one :mentor, through: :mentor_profile, source: :user
  has_many :profile_declarations

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }
end
