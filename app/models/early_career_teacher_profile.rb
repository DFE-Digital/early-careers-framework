# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true
  has_one :participation_record
end
