# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateInductionTutorReminderJob do
  let(:school) { FactoryBot.create(:seed_school) }
  let(:fake_reminder) { double(UpdateInductionTutorReminder, send!: true) }

  before do
    allow(UpdateInductionTutorReminder).to receive(:new).with(any_args).and_return(fake_reminder)
  end

  describe "#perform" do
    it "triggers the creation and sending of an UpdateInductionTutorReminder" do
      UpdateInductionTutorReminderJob.perform_now(school)

      expect(UpdateInductionTutorReminder).to have_received(:new).with(school)
      expect(fake_reminder).to have_received(:send!)
    end
  end
end
