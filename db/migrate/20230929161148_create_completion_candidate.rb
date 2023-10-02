# frozen_string_literal: true

class CreateCompletionCandidate < ActiveRecord::Migration[7.0]
  def change
    create_table(:completion_candidates, primary_key: :participant_profile_id, id: false) do |t|
      t.uuid :participant_profile_id
      t.index :participant_profile_id, unique: true
    end

    add_foreign_key :completion_candidates, :participant_profiles, on_delete: :cascade, validate: false
  end
end
