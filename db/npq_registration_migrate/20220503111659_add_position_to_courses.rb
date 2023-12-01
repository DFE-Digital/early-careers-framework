class AddPositionToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :position, :integer, default: 0
  end
end
