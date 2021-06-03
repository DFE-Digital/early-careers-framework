# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  has_many :participant_bands
  belongs_to :lead_provider

  def band_a
    bands.first
  end

private

  def bands
    participant_bands.min_nulls_first
  end
end
