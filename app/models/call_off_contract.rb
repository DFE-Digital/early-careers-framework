# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  has_many :participant_bands
  belongs_to :lead_provider

  def band_a
    participant_bands.order(:min).first
  end
end
