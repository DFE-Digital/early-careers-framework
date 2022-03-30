# frozen_string_literal: true

class CreateScheduleMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :schedule_milestones do |t|
      t.string :name,             null: false
      t.belongs_to :schedule,     null: false, foreign_key: true
      t.belongs_to :milestone,    null: false, foreign_key: true
      t.string :declaration_type, null: false
      t.timestamps
    end
  end
end
