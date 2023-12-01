class AddDisplayToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :display, :boolean, default: true
  end
end
