# frozen_string_literal: true

class AddPaymentsClosedAtToCohorts < ActiveRecord::Migration[7.1]
  def change
    add_column :cohorts, :payments_frozen_at, :datetime
  end
end
