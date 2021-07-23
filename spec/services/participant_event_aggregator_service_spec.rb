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
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }

  context "event declarations" do
    before do
      10.times do
        participant_declaration = create(:participant_declaration, cpd_lead_provider: cpd_lead_provider)
        create(:participant_declaration, user: participant_declaration.user, cpd_lead_provider: cpd_lead_provider)
      end
    end

    describe ".call" do
      context "aggregate using ParticipantDeclaration" do
        it "returns a count of the unique started events" do
          expect(described_class.call({ cpd_lead_provider: cpd_lead_provider })).to eq(10)
        end
      end

      it "can be injected with a different recorder" do
        expect(described_class.call({ recorder: DummyRecorder, cpd_lead_provider: cpd_lead_provider })).to eq(100)
      end

      it "can be injected with a different recorder and different scope" do
        expect(described_class.call({ recorder: DummyRecorder, started: :count_something_else, cpd_lead_provider: cpd_lead_provider })).to eq(40)
      end
    end
  end
end
