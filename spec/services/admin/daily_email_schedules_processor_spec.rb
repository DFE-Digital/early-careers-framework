# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DailyEmailSchedulesProcessor do
  let(:mailer_name) { EmailSchedule::MAILERS.keys.sample }
  let(:mailer_method) { EmailSchedule::MAILERS[mailer_name] }
  let(:today_schedule) { create(:seed_email_factory, :scheduled_for_today, mailer_name:) }
  let(:future_schedule) { create(:seed_email_factory) }
  let(:past_schedule) { create(:seed_email_factory, :sent) }
  let(:running_schedule) { create(:seed_email_factory, :sending) }
  let(:cohort) { Cohort.current }

  subject { described_class.new }

  describe "#initialize" do
    it "retrieves the email schedules to be sent today" do
      expect(subject.email_schedules).to include(today_schedule)
    end

    it "doesn't retrieves email schedules not schedueled to be sent today" do
      expect(subject.email_schedules).to_not include([running_schedule, past_schedule, future_schedule])
    end
  end

  describe "#call" do
    let(:school_reminder_comms) { instance_double(BulkMailers::SchoolReminderComms) }

    before do
      allow(BulkMailers::SchoolReminderComms).to receive(:new).with(cohort:, email_schedule: today_schedule).and_return(school_reminder_comms)
      allow(school_reminder_comms).to receive(mailer_method)
    end

    it "calls the school reminder bulk mailer to send comms" do
      expect(school_reminder_comms).to receive(:send).with(mailer_method)
      subject.call
    end

    it "changes the status of the email schedule to sent" do
      expect { subject.call }.to change { today_schedule.reload.status }.to("sent")
    end
  end
end
