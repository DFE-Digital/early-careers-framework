class ChangePrimaryKeyToUuidOnInductionCoordinatorProfilesSchools < ActiveRecord::Migration[6.1]
  def up
    add_column :induction_coordinator_profiles_schools, :uuid_id, :uuid, default: "gen_random_uuid()", null: false
    rename_column :induction_coordinator_profiles_schools, :id, :integer_id
    rename_column :induction_coordinator_profiles_schools, :uuid_id, :id
    execute "ALTER TABLE induction_coordinator_profiles_schools DROP CONSTRAINT induction_coordinator_profiles_schools_pkey;"
    execute "ALTER TABLE induction_coordinator_profiles_schools ADD PRIMARY KEY (id);"

    remove_column :induction_coordinator_profiles_schools, :integer_id
    execute "DROP SEQUENCE IF EXISTS induction_coordinator_profiles_schools_id_seq;"
  end

  def down
    execute "CREATE SEQUENCE IF NOT EXISTS induction_coordinator_profiles_schools_id_seq;"
    execute "ALTER TABLE induction_coordinator_profiles_schools ADD COLUMN integer_id bigint NOT NULL DEFAULT nextval('induction_coordinator_profiles_schools_id_seq');"
    rename_column :induction_coordinator_profiles_schools, :id, :uuid_id
    rename_column :induction_coordinator_profiles_schools, :integer_id, :id
    execute "ALTER TABLE induction_coordinator_profiles_schools DROP CONSTRAINT induction_coordinator_profiles_schools_pkey;"
    execute "ALTER TABLE induction_coordinator_profiles_schools ADD PRIMARY KEY (id);"

    remove_column :induction_coordinator_profiles_schools, :uuid_id
  end
end
