# frozen_string_literal: true

class MakeUserIdUniqueOnTeacherProfiles < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :teacher_profiles, :user_id
    add_index :teacher_profiles, :user_id, unique: true, algorithm: :concurrently
  end
end
