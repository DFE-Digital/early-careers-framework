# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::EmailSchedulesJob do
  subject(:job) { described_class.perform_later }

  describe "#perform" do
    it "queues the job" do
      expect { job }.to have_enqueued_job
    end

    it "executes perform" do
      expect(Admin::DailyEmailSchedulesProcessor).to receive(:call)
      perform_enqueued_jobs { job }
    end
  end
end
