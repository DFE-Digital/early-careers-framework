# frozen_string_literal: true

class AddNPQRegistrationStartDateToCohorts < ActiveRecord::Migration[6.1]
  def change
    add_column :cohorts, :npq_registration_start_date, :datetime
  end
end
