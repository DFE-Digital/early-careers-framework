# frozen_string_literal: true

class AddRegistrationDatesToCohort < ActiveRecord::Migration[6.1]
  def change
    add_column :cohorts, :registration_start_date, :datetime
    add_column :cohorts, :academic_year_start_date, :datetime
  end
end
