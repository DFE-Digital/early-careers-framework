# frozen_string_literal: true

class CreateSchoolDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :school_domains, id: :uuid do |t|
      t.timestamps
      t.column :domain, :string, null: false
      t.index :domain, unique: true
    end
    create_join_table :school_domains, :schools, column_options: { type: :uuid } do |t|
      t.timestamps null: false
    end
  end
end
