# frozen_string_literal: true

class AddIndiciesToSchools < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :schools, %i[section_41_approved school_status_code], where: :section_41_approved, algorithm: :concurrently
    add_index :schools, %i[school_type_code school_status_code], algorithm: :concurrently
  end
end
