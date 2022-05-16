# frozen_string_literal: true

class DropOriginalFundingFlag < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :npq_applications, :targeted_support_funding_eligibility, :boolean, default: false
    end
  end
end
