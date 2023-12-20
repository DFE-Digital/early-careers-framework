class AddTeacherCatchments < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :teacher_catchment, :text, null: true
    add_column :applications, :teacher_catchment_country, :text, null: true
  end
end
