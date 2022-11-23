# frozen_string_literal: true

class AddTargetedDeliveryFundingPerParticipantToNPQContracts < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_contracts, :targeted_delivery_funding_per_participant, :decimal, default: 100.0
  end
end
