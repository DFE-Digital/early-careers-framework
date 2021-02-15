# frozen_string_literal: true

class PupilPremium < ApplicationRecord
  THRESHOLD_PERCENTAGE = 40

  belongs_to :school

  def uplift?
    percentage_eligible >= THRESHOLD_PERCENTAGE
  end

  scope :only_with_uplift, lambda { |start_year|
    where(start_year: start_year)
      .where("total_pupils > 0 AND (CAST(eligible_pupils AS float) / total_pupils) * 100 >= ?", THRESHOLD_PERCENTAGE)
  }

private

  def percentage_eligible
    (eligible_pupils.to_f / total_pupils) * 100
  end
end
