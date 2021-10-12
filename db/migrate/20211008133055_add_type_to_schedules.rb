# frozen_string_literal: true

class AddTypeToSchedules < ActiveRecord::Migration[6.1]
  def change
    add_column :schedules, :type, :string, default: "Finance::Schedule::ECF"
  end
end
