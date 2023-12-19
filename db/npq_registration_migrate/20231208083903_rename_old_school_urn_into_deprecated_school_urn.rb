class RenameOldSchoolUrnIntoDeprecatedSchoolUrn < ActiveRecord::Migration[7.0]
  def change
    rename_column :applications, :school_urn_old, :DEPRECATED_school_urn
  end
end
