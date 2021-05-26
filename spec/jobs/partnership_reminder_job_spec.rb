# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PartnershipReminderJob" do
  describe "#perform" do
    it "Does nothing if the partnership has been challenged" do
      partnership = create(:partnership, :challenged)
      expect_any_instance_of(PartnershipNotificationService).not_to receive(:send_reminder)

      PartnershipReminderJob.new.perform(partnership)
    end
  end
end
