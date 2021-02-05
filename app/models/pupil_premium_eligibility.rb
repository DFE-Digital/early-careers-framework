# frozen_string_literal: true

class PupilPremiumEligibility < ApplicationRecord
  THRESHOLD_PERCENTAGE = 40

  belongs_to :school

  def uplift?
    percent_primary_pupils_eligible >= THRESHOLD_PERCENTAGE || percent_secondary_pupils_eligible >= THRESHOLD_PERCENTAGE
  end

  scope :only_with_uplift, lambda { |start_year|
    where("start_year = ? AND (percent_primary_pupils_eligible >= ? OR percent_secondary_pupils_eligible >= ?)",
          start_year,
          THRESHOLD_PERCENTAGE,
          THRESHOLD_PERCENTAGE)
  }
end
