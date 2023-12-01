class CreateRegistrationInterests < ActiveRecord::Migration[6.1]
  def change
    enable_extension("citext")

    create_table :registration_interests do |t|
      t.citext :email, null: false, index: { unique: true }
      t.boolean :notified, default: false

      t.timestamps
    end
  end
end
