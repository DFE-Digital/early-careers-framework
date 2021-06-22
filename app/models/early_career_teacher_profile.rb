# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort
  belongs_to :mentor_profile, optional: true
  has_one :mentor, through: :mentor_profile, source: :user
  has_one :participation_record, dependent: :destroy
  has_many :participant_declarations
end
