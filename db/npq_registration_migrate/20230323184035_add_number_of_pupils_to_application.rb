class AddNumberOfPupilsToApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :number_of_pupils, :integer, default: 0
  end
end
