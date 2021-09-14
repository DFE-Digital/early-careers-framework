# frozen_string_literal: true

class AddLaCodeToDataStageSchool < ActiveRecord::Migration[6.1]
  def change
    add_column :data_stage_schools, :la_code, :string
  end
end
