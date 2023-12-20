class PopulateSchoolIdInApplications < ActiveRecord::Migration[7.0]
  def up
    # Use SQL to update the school_id column based on school_urn
    execute <<-SQL
      UPDATE applications
      SET school_id = schools.id
      FROM schools
      WHERE applications.school_urn = schools.urn
    SQL
  end

  def down; end
end
