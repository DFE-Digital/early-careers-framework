class ApplicationSchoolUrnNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :applications, :school_urn, true
  end
end
