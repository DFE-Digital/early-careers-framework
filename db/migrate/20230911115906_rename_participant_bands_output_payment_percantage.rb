# frozen_string_literal: true

class RenameParticipantBandsOutputPaymentPercantage < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :participant_bands, :output_payment_percantage, :output_payment_percentage
    end
  end
end
