# frozen_string_literal: true

# == Schema Info
# Table name: call_off_contracts
#
# id  :uuid not null, primary
# raw :jsonb
# uplift_target :decimal
# uplift_amount :decimal
# recruitment_target :integer
# set_up_fee :decimal
# timestamps

class CallOffContract < ApplicationRecord
  has_many :participant_bands

  def band_a
    participant_bands.order(:min).first
  end
end
