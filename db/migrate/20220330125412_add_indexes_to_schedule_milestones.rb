# frozen_string_literal: true

class AddIndexesToScheduleMilestones < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :schedule_milestones, %i[schedule_id milestone_id declaration_type],
              unique: true, algorithm: :concurrently, name: :schedules_milestones_schedule_milestone_declaration_type

    add_index :schedule_milestones, %i[milestone_id schedule_id declaration_type],
              unique: true, algorithm: :concurrently, name: :milestones_schedules_schedule_milestone_declaration_type
  end
end
