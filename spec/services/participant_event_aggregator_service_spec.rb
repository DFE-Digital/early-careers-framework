# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantEventAggregator do
  let(:lead_provider) { create(:lead_provider) }

  context "event declarations" do
    before do
      10.times do
        participant_declaration = create(:participant_declaration, lead_provider: lead_provider)
        create(:participant_declaration, early_career_teacher_profile: participant_declaration.early_career_teacher_profile, lead_provider: lead_provider)
        participant_record = create(:participation_record, lead_provider: lead_provider)
        participant_record.join!
      end
    end

    describe ".call" do
      it "returns a count of the unique started events" do
        expect(described_class.call(lead_provider)).to eq(10)
      end
    end
  end
end
