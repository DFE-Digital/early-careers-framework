# frozen_string_literal: true

class AddUpdatedByAndEligibleForFundingUpdatedAtToNPQApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :npq_applications, :eligible_for_funding_updated_by_id, :uuid
    add_column :npq_applications, :eligible_for_funding_updated_at, :datetime
  end
end
