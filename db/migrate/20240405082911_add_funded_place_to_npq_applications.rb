# frozen_string_literal: true

class AddFundedPlaceToNPQApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :npq_applications, :funded_place, :boolean
  end
end
