class CreateIdentities < ActiveRecord::Migration[6.1]
  def change
    create_table :identities, id: :uuid  do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.citext :email, null: false
      t.uuid :external_identifier
      t.string :origin, default: "ecf", null: false

      t.index :email, unique: true
      t.index :external_identifier, unique: true

      t.timestamps
    end
  end
end
