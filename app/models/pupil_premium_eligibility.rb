# frozen_string_literal: true

class PupilPremiumEligibility < ApplicationRecord
  THRESHOLD_PERCENTAGE = 40

  belongs_to :school

  def uplift?
    percent_primary_pupils_eligible >= THRESHOLD_PERCENTAGE || percent_secondary_pupils_eligible >= THRESHOLD_PERCENTAGE
  end
end
