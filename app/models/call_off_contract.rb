# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  belongs_to :lead_provider
  delegate :total_contract_value, to: :bands
  has_many :participant_bands do
    def total_contract_value
      map(&:contract_value).reduce(&:+)
    end
  end

  def uplift_cap
    total_contract_value * 0.05
  end

  def band_a
    bands.first
  end

  def bands
    participant_bands.min_nulls_first
  end

  delegate :set_up_recruitment_basis, to: :band_a
end
