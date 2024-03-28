# frozen_string_literal: true

class ChangeCountFieldsInEmailSchedules < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :email_schedules, :failed_email_count
      remove_column :email_schedules, :actual_email_count
    end

    add_column :email_schedules, :emails_sent_count, :integer
  end
end
