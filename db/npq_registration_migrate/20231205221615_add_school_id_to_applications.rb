class AddSchoolIdToApplications < ActiveRecord::Migration[7.0]
  def change
    add_reference :applications, :school, null: true, foreign_key: true
  end
end
