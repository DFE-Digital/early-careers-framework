# frozen_string_literal: true

class AddPrimaryKeyToInductionCoordinatorProfilesSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :induction_coordinator_profiles_schools, :id, :primary_key
  end
end
