# frozen_string_literal: true

class AddDisableFromYearToAppropriateBodies < ActiveRecord::Migration[6.1]
  def change
    add_column :appropriate_bodies, :disable_from_year, :integer, null: true
  end
end
