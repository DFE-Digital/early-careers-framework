# frozen_string_literal: true

class AddPartnershipNotificationEmailToNominationEmail < ActiveRecord::Migration[6.1]
  def change
    add_reference :nomination_emails, :partnership_notification_email, null: true, foreign_key: true, type: :uuid
  end
end
