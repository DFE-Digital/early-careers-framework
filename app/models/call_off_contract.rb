# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  has_many :participant_bands
  has_many :lead_providers

  def band_a
    participant_bands.order(:min).first
  end
end
