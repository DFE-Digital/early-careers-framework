# frozen_string_literal: true

class AddIndexToCohortsOnStartYear < ActiveRecord::Migration[6.1]
  def change
    add_index :cohorts, :start_year, unique: true
  end
end
