# frozen_string_literal: true

class AddEligibleForFundingUpdatedByToApplications < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :npq_applications, :users, column: :eligible_for_funding_updated_by_id, validate: false
  end
end
