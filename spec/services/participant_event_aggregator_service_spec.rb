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

  context "event declarations" do
    before do
      10.times do
        participant_declaration = create(:participant_declaration, lead_provider: lead_provider)
        create(:participant_declaration, user: participant_declaration.user, lead_provider: lead_provider)
        participant_record = create(:participation_record, lead_provider: lead_provider)
        participant_record.join!
      end
    end

    describe ".call" do
      context "aggregate using ParticipationRecorder" do
        it "returns a count of the active participants" do
          expect(described_class.call({ recorder: ParticipationRecord, lead_provider: lead_provider })).to eq(10)
        end
      end

      context "aggregate using ParticipantDeclaration" do
        it "returns a count of the unique started events" do
          expect(described_class.call({ lead_provider: lead_provider })).to eq(10)
        end
      end

      it "can be injected with a different recorder" do
        expect(described_class.call({ recorder: DummyRecorder, lead_provider: lead_provider })).to eq(100)
      end

      it "can be injected with a different recorder and different scope" do
        expect(described_class.call({ recorder: DummyRecorder, started: :count_something_else, lead_provider: lead_provider })).to eq(40)
      end
    end
  end
end
