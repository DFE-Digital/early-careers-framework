# frozen_string_literal: true

class AddPrimaryEligibilityAndPupilFieldsToNPQApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :primary_establishment, :boolean, default: false
    add_column :npq_applications, :number_of_pupils, :integer, default: 0
    add_column :npq_applications, :tsf_primary_eligibility, :boolean, default: false
    add_column :npq_applications, :tsf_primary_plus_eligibility, :boolean, default: false
  end
end
