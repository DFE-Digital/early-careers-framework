# frozen_string_literal: true

class ChangeDatatypesInSchools < ActiveRecord::Migration[6.1]
  def self.up
    change_table :schools, bulk: true do |t|
      t.change :school_type_code, "integer USING CAST(school_type_code AS integer)"
      t.change :school_phase_type, "integer USING CAST(school_phase_type AS integer)"
      t.change :school_status_code, "integer USING CAST(school_status_code AS integer)"
    end
  end

  def self.down
    change_table :schools, bulk: true do |t|
      t.change :school_type_code, :string
      t.change :school_phase_type, :string
      t.change :school_status_code, :string
    end
  end
end
