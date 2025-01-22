# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  belongs_to :lead_provider
  belongs_to :cohort

  has_many :participant_bands

  def total_contract_value
    participant_bands.map(&:contract_value).sum
  end

  def uplift_cap
    (total_contract_value * 0.05).ceil(-2)
  end

  def band_a
    bands.first
  end

  def bands
    participant_bands.min_nulls_first
  end

  def include_uplift_fees?
    !uplift_amount.nil?
  end

  delegate :set_up_recruitment_basis, to: :band_a
end
