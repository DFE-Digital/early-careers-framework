# frozen_string_literal: true

class AddNotesToNPQApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :notes, :string
  end
end
