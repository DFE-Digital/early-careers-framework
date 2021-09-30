# frozen_string_literal: true

class CreateSchedulesAndMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules, id: :uuid do |t|
      t.text :name, null: false

      t.timestamps
    end

    create_table :milestones, id: :uuid do |t|
      t.text :name, null: false
      t.date :milestone_date, null: false
      t.date :payment_date, null: false
      t.references :schedule, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
