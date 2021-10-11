# frozen_string_literal: true

class AddStartDateToMilestones < ActiveRecord::Migration[6.1]
  def change
    add_column :milestones, :start_date, :date
  end
end
