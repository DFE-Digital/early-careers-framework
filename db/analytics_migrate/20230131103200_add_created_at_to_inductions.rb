# frozen_string_literal: true

class AddCreatedAtToInductions < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_inductions, :induction_record_created_at, :datetime
  end
end
