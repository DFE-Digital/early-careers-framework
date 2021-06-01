# frozen_string_literal: true

class CreateAdditionalSchoolEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :additional_school_emails do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.string :email_address, null: false

      t.timestamps
    end

    add_index :additional_school_emails, %i[email_address school_id], unique: true
  end
end
