# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipReminderJob do
  describe "#perform" do
    let(:partnership) { create :partnership }
    let(:report_id) { partnership.report_id }

    let(:notification_service) { instance_spy PartnershipNotificationService }

    before do
      allow(PartnershipNotificationService).to receive(:new).and_return notification_service
      subject.perform(partnership: partnership, report_id: report_id)
    end

    it "send partnership reminders" do
      expect(notification_service).to have_received(:send_reminder).with(partnership)
    end

    context "when partnership has been challenged" do
      let(:partnership) { create :partnership, :challenged }

      it "does nothing" do
        expect(notification_service).not_to have_received(:send_reminder)
      end
    end

    context "when given report_id does not match the report_id on the partnership" do
      let(:report_id) { Random.uuid }

      it "does nothing" do
        expect(notification_service).not_to have_received(:send_reminder)
      end
    end
  end
end
