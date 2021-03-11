class RemoveDiscardOnEct < ActiveRecord::Migration[6.1]
  def change
    remove_index :early_career_teacher_profiles, :discarded_at
    remove_column :early_career_teacher_profiles, :discarded_at
  end
end
