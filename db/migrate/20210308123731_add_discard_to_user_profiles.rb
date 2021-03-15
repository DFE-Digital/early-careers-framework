# frozen_string_literal: true

class AddDiscardToUserProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :lead_provider_profiles, :discarded_at, :datetime
    add_index :lead_provider_profiles, :discarded_at

    add_column :induction_coordinator_profiles, :discarded_at, :datetime
    add_index :induction_coordinator_profiles, :discarded_at

    add_column :early_career_teacher_profiles, :discarded_at, :datetime
    add_index :early_career_teacher_profiles, :discarded_at

    add_column :admin_profiles, :discarded_at, :datetime
    add_index :admin_profiles, :discarded_at
  end
end
