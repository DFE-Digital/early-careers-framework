# frozen_string_literal: true

class AddSection41ApprovedToDataStageSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :data_stage_schools, :section_41_approved, :boolean
  end
end
