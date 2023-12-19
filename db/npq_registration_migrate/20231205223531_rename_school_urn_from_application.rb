class RenameSchoolUrnFromApplication < ActiveRecord::Migration[7.0]
  def change
    rename_column :applications, :school_urn, :school_urn_old
  end
end
