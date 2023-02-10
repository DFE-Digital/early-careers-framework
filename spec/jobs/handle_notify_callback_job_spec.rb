# frozen_string_literal: true

require "rails_helper"

RSpec.describe(HandleNotifyCallbackJob, :with_default_schedules) do
  let(:one_hour_ago) { 1.hour.ago }
  let!(:email) { Email.create(id: notify_email.notify_id) }

  context "when the email is a partnership notification email" do
    let!(:notify_email) { FactoryBot.create(:partnership_notification_email) }

    it "updates the partnership notification email record" do
      expect(notify_email.notify_status).to be_blank
      expect(email.status).to eq("submitted")
      expect(email.delivered_at).to be_blank

      HandleNotifyCallbackJob.new.perform(
        email_id: notify_email.notify_id,
        delivery_status: "delivered",
        sent_at: one_hour_ago.to_s,
      )

      notify_email.reload
      email.reload

      expect(notify_email.notify_status).to eq("delivered")
      expect(email.status).to eq("delivered")
      expect(email.delivered_at).to eq(one_hour_ago.to_s)
    end
  end

  context "when the email is a nomination email" do
    let!(:notify_email) { FactoryBot.create(:nomination_email) }

    it "updates the nomination email record" do
      expect(notify_email.notify_status).to be_blank
      expect(email.status).to eq("submitted")
      expect(email.delivered_at).to be_blank

      HandleNotifyCallbackJob.new.perform(
        email_id: notify_email.notify_id,
        delivery_status: "delivered",
        sent_at: one_hour_ago.to_s,
      )

      notify_email.reload
      email.reload

      expect(notify_email.notify_status).to eq("delivered")
      expect(email.status).to eq("delivered")
      expect(email.delivered_at).to eq(one_hour_ago.to_s)
    end
  end
end
