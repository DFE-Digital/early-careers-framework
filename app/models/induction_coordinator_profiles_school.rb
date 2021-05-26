# frozen_string_literal: true

class InductionCoordinatorProfilesSchool < ApplicationRecord
  has_paper_trail

  belongs_to :induction_coordinator_profile
  belongs_to :school
end
