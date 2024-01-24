# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailSchedule, type: :model do
  it { is_expected.to validate_inclusion_of(:mailer_name).in_array(EmailSchedule::MAILERS.keys.map(&:to_s)) }
  it { is_expected.to validate_presence_of(:scheduled_at) }

  describe "scopes" do
    let!(:scheduled_today) { create(:seed_email_factory, :scheduled_for_today) }
    let!(:scheduled_later) { create(:seed_email_factory) }
    let!(:already_sent) { create(:seed_email_factory, :sent) }
    let!(:currently_sending) { create(:seed_email_factory, :sending) }

    describe ".to_send_today" do
      it "returns the queued schedules for today" do
        expect(described_class.to_send_today).to match_array [scheduled_today]
      end

      it "does not include schedules for a later date" do
        expect(described_class.to_send_today).not_to include [scheduled_later]
      end

      it "does not include schedules that are in progress" do
        expect(described_class.to_send_today).not_to include [currently_sending]
      end

      it "does not include schedules that have already been sent" do
        expect(described_class.to_send_today).not_to include [already_sent]
      end
    end
  end
end
