# frozen_string_literal: true

class AddLeadMentorAndIttProviderToNPQApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_applications, :itt_provider, :string
    add_column :npq_applications, :lead_mentor, :boolean, default: false
  end
end
