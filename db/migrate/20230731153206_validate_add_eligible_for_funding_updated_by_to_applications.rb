# frozen_string_literal: true

class ValidateAddEligibleForFundingUpdatedByToApplications < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :npq_applications, :users
  end
end
