class AddFundingEligiblityStatusCodeToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :funding_eligiblity_status_code, :string
  end
end
