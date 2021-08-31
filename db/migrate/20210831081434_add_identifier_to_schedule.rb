# frozen_string_literal: true

class AddIdentifierToSchedule < ActiveRecord::Migration[6.1]
  def change
    add_column :schedules, :schedule_identifier, :string
  end
end
