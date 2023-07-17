# frozen_string_literal: true

class ChangeScheduleMilestonesIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    remove_index :schedule_milestones, name: "milestones_schedules_schedule_milestone_declaration_type", if_exists: true
    remove_index :schedule_milestones, name: "schedules_milestones_schedule_milestone_declaration_type", if_exists: true
    add_index :schedule_milestones, %i[milestone_id schedule_id], name: :index_schedule_milestones_on_milestone_id_and_schedule_id, algorithm: :concurrently, if_not_exists: true
    add_index :schedule_milestones, %i[schedule_id milestone_id], name: :index_schedule_milestones_on_schedule_id_and_milestone_id, algorithm: :concurrently, if_not_exists: true
  end

  def down
    add_index :schedule_milestones, %i[milestone_id schedule_id declaration_type], name: "milestones_schedules_schedule_milestone_declaration_type", algorithm: :concurrently, if_not_exists: true
    add_index :schedule_milestones, %i[schedule_id milestone_id declaration_type], name: "schedules_milestones_schedule_milestone_declaration_type", algorithm: :concurrently, if_not_exists: true
    remove_index :schedule_milestones, name: :index_schedule_milestones_on_milestone_id_and_schedule_id, if_exists: true
    remove_index :schedule_milestones, name: :index_schedule_milestones_on_schedule_id_and_milestone_id, if_exists: true
  end
end
