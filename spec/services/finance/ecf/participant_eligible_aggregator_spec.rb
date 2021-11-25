# frozen_string_literal: true

RSpec.describe Finance::ECF::ParticipantEligibleAggregator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }

  describe "::call" do
    before do
      create(:ect_participant_declaration, cpd_lead_provider: cpd_lead_provider)
    end

    context "without an interval" do
      it "returns all declarations" do
        expect(described_class.call(cpd_lead_provider: cpd_lead_provider)).to eql(
          {
            all: 0,
            ects: 0,
            mentors: 0,
            not_yet_included: 1,
            uplift: 0,
          },
        )
      end
    end

    context "with an interval" do
      it "returns declarations within interval" do
        expect(described_class.call(cpd_lead_provider: cpd_lead_provider, interval: 2.years.ago..1.year.ago)).to eql(
          {
            all: 0,
            ects: 0,
            mentors: 0,
            not_yet_included: 0,
            uplift: 0,
          },
        )
      end
    end
  end
end
