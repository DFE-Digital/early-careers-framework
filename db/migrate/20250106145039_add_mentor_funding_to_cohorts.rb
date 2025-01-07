# frozen_string_literal: true

class AddMentorFundingToCohorts < ActiveRecord::Migration[7.1]
  def change
    add_column :cohorts, :mentor_funding, :boolean, null: false, default: false
  end
end
