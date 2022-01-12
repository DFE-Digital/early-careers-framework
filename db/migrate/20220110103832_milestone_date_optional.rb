# frozen_string_literal: true

class MilestoneDateOptional < ActiveRecord::Migration[6.1]
  def change
    change_column_null :milestones, :milestone_date, true
  end
end
