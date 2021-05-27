# frozen_string_literal: true

class InductionCoordinatorProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  has_many :induction_coordinator_profiles_schools, dependent: :destroy
  has_many :schools, through: :induction_coordinator_profiles_schools
end
