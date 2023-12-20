class AddUkprnToApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :ukprn, :text, null: true
  end
end
