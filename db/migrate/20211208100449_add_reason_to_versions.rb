# frozen_string_literal: true

class AddReasonToVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :versions, :reason, :string
  end
end
