# frozen_string_literal: true

class RemovePupilCountsFromPupilPremiums < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :pupil_premiums, :total_pupils, :integer, limit: 2, null: false
      remove_column :pupil_premiums, :eligible_pupils, :integer, null: false
    end
  end
end
