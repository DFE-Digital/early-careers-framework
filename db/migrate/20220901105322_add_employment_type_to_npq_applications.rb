# frozen_string_literal: true

class AddEmploymentTypeToNPQApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :employment_type, :string
  end
end
