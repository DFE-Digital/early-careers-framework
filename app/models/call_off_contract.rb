# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  has_many :participant_bands

  def band_a
    participant_bands.order(:min).first
  end
end
