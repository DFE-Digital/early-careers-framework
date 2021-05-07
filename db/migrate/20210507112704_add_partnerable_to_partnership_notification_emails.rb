# frozen_string_literal: true

class AddPartnerableToPartnershipNotificationEmails < ActiveRecord::Migration[6.1]
  def up
    add_reference :partnership_notification_emails, :partnerable, polymorphic: true, index: true
    PartnershipNotificationEmail.all.each do |email|
      email.update!(partnerable_type: "Partnership", partnerable_id: email.partnership_id)
    end
    remove_index :partnership_notification_emails, :partnership_id
    remove_column :partnership_notification_emails, :partnership_id
  end

  def down
    add_reference :partnership_notification_emails, :partnership, index: true, foreign_key: true
    PartnershipNotificationEmail.all.each do |email|
      email.update!(partnership_id: email.partnerable_id) if email.partnerable_type == "Partnership"
    end
    change_table :partnership_notification_emails, bulk: true do
      remove_index :partnership_notification_emails, column: %i[partnerable_type partnerable_id]
      remove_column :partnership_notification_emails, :partnerable_type
      remove_column :partnership_notification_emails, :partnerable_id
    end
  end
end
