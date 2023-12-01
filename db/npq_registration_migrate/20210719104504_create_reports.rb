class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.text :identifier, null: false
      t.text :data, null: true

      t.timestamps
    end
  end
end
