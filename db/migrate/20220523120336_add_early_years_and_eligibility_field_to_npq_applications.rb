# frozen_string_literal: true

class AddEarlyYearsAndEligibilityFieldToNPQApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :works_in_nursery, :boolean
    add_column :npq_applications, :works_in_childcare, :boolean
    add_column :npq_applications, :kind_of_nursery, :string
    add_column :npq_applications, :private_childcare_provider_urn, :string
    add_column :npq_applications, :funding_eligiblity_status_code, :string
  end
end
