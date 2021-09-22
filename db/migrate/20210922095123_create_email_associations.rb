class CreateEmailAssociations < ActiveRecord::Migration[6.1]
  def change
    create_table :email_associations do |t|
      t.references :email, foreign_key: true, index: true
      t.references :object, polymorphic: true
      t.string :name

      t.timestamps
    end
  end
end
