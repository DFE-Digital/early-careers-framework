# frozen_string_literal: true

class PupilPremium < ApplicationRecord
  belongs_to :school

  def uplift?
    pupil_premium_incentive?
  end

  def sparse?
    sparsity_incentive?
  end

  scope :with_start_year, ->(start_year) { where(start_year:) }
  scope :only_with_uplift, ->(start_year) { with_start_year(start_year).where(pupil_premium_incentive: true) }
  scope :only_with_sparsity, ->(start_year) { with_start_year(start_year).where(sparsity_incentive: true) }
end
