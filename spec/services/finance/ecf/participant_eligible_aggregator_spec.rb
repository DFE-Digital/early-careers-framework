# frozen_string_literal: true

RSpec.describe Finance::ECF::ParticipantEligibleAggregator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:statement) { create(:ecf_statement, cpd_lead_provider: cpd_lead_provider) }

  describe "::call" do
    before do
      create(:ect_participant_declaration, cpd_lead_provider: cpd_lead_provider, statement: statement)
    end

    it "returns all declarations" do
      expect(described_class.new(statement: statement).call(event_type: :started)).to eql(
        {
          all: 0,
          ects: 0,
          mentors: 0,
          not_yet_included: 1,
          uplift: 0,
          previous_participants: 0,
        },
      )
    end
  end
end
