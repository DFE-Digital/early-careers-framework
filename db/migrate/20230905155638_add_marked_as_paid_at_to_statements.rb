# frozen_string_literal: true

class AddMarkedAsPaidAtToStatements < ActiveRecord::Migration[7.0]
  def change
    add_column :statements, :marked_as_paid_at, :datetime
  end
end
