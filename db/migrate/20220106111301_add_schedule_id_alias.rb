# frozen_string_literal: true

class AddScheduleIdAlias < ActiveRecord::Migration[6.1]
  def change
    add_column :schedules, :identifier_alias, :text, null: true
  end
end
