# frozen_string_literal: true

class CreateContinueTrainingCohortChangeErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :continue_training_cohort_change_errors, if_not_exists: true do |t|
      t.belongs_to :participant_profile, null: false, foreign_key: true, type: :uuid, index: { name: "continue_training_error_participant_profile_id" }
      t.text :message

      t.timestamps
    end
  end
end
