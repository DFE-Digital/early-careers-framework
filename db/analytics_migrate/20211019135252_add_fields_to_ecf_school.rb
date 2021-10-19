# frozen_string_literal: true

class AddFieldsToECFSchool < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_schools, :active_participants, :boolean
  end
end
