# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Performance::EmailSchedulesHelper, type: :helper do
  let(:cohort) { Cohort.current }
  let(:sent_schedule) { build(:seed_email_factory, :sent, emails_sent_count: 10) }

  describe "#email_schedule_estimated" do
    let(:school_bulk_mailers) { instance_double(BulkMailers::SchoolReminderComms) }
    let(:today_schedule) { build(:seed_email_factory, :scheduled_for_today) }

    it "returns the estimated emails the email schedule will sent" do
      expect(BulkMailers::SchoolReminderComms).to receive(:new).with(cohort:, dry_run: true).and_return(school_bulk_mailers)
      allow(school_bulk_mailers).to receive(today_schedule.mailer_method).and_return(10)

      expect(email_schedule_estimated(today_schedule)).to eq("10 emails")
    end
  end

  describe "#email_schedule_sent" do
    it "returns the emails sent by the email schedule" do
      expect(email_schedule_sent(sent_schedule)).to eq("10 emails")
    end
  end

  describe "#email_schedule_bounced" do
    it "returns a string in the correct format" do
      allow(Email).to receive_message_chain(:failed, :associated_with, :count).and_return(5)

      expect(email_schedule_bounced(sent_schedule)).to eq("5 (50.0%)")
    end
  end

  describe "#calculate_percentage" do
    it "calculates the percentage correctly" do
      expect(calculate_percentage(50, 100)).to eq(50.0)
    end

    it "returns 0.0 if the whole is 0 to avoid division by zero" do
      expect(calculate_percentage(50, 0)).to eq(0)
    end

    it "returns 0.0 if the part is 0" do
      expect(calculate_percentage(0, 100)).to eq(0)
    end

    it "handles decimals correctly" do
      expect(calculate_percentage(2.5, 10)).to eq(25.0)
    end

    it "returns a float value" do
      expect(calculate_percentage(1, 3)).to be_a(Float)
    end
  end
end
