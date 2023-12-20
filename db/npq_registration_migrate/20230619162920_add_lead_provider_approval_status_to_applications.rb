class AddLeadProviderApprovalStatusToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :lead_provider_approval_status, :text
    add_column :applications, :participant_outcome_state, :text
  end
end
