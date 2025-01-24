# frozen_string_literal: true

class RemoveNPQRegistrationStartDateFromCohorts < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :cohorts, :npq_registration_start_date, :datetime, precision: nil }
  end
end
