# frozen_string_literal: true

class CreateAdditionalSchoolEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :additional_school_emails do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false

      t.timestamps
    end
  end
end
