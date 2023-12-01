class AddIttProviderAndLeadMentorToApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :itt_provider, :string
    add_column :applications, :lead_mentor, :boolean, default: false
  end
end
