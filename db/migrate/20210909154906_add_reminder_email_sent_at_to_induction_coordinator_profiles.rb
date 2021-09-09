# frozen_string_literal: true

class AddReminderEmailSentAtToInductionCoordinatorProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :induction_coordinator_profiles, :reminder_email_sent_at, :datetime
  end
end
