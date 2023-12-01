class AddNumberOfPupilsToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :number_of_pupils, :integer
  end
end
