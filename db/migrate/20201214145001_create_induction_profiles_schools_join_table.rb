# frozen_string_literal: true

class CreateInductionProfilesSchoolsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :induction_coordinator_profiles, :schools, column_options: { type: :uuid } do |t|
      t.timestamps null: false
      t.index :induction_coordinator_profile_id, name: "index_icp_schools_on_icp"
      t.index :school_id, name: "index_icp_schools_on_schools"
    end
  end
end
