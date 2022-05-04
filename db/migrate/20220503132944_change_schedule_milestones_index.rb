# frozen_string_literal: true

class ChangeScheduleMilestonesIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :schedule_milestones, column: %i[schedule_id milestone_id declaration_type], name: :schedules_milestones_schedule_milestone_declaration_type
    remove_index :schedule_milestones, column: %i[milestone_id schedule_id declaration_type], name: :milestones_schedules_schedule_milestone_declaration_type

    add_index :schedule_milestones, %i[schedule_id milestone_id], algorithm: :concurrently

    add_index :schedule_milestones, %i[milestone_id schedule_id], algorithm: :concurrently
  end
end
