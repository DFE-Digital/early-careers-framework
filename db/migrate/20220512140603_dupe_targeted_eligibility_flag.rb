# frozen_string_literal: true

class DupeTargetedEligibilityFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :targeted_delivery_funding_eligibility, :boolean, default: false
  end
end
