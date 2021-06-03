# frozen_string_literal: true

require "rails_helper"

class DummyRecorder
  class << self
    def count_active_for_lead_provider(*)
      100
    end

    def count_something_else(*)
      40
    end
  end
end

RSpec.describe ParticipantEventAggregator do
  let(:lead_provider) { create(:lead_provider) }

  before do
    10.times do
      pr = create(:participation_record, lead_provider: lead_provider)
      pr.join!
      create(:participation_record, lead_provider: lead_provider)
    end
  end

  context ".call" do
    it "returns a count of the active participants" do
      expect(described_class.call({ lead_provider: lead_provider })).to eq(10)
    end

    it "can be injected with a different recorder" do
      expect(described_class.call({ recorder: DummyRecorder, lead_provider: lead_provider })).to eq(100)
    end

    it "can be injected with a different recorder and different scope" do
      expect(described_class.call({ recorder: DummyRecorder, start: :count_something_else, lead_provider: lead_provider })).to eq(40)
    end
  end
end
