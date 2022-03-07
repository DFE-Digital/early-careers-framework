# frozen_string_literal: true

RSpec.describe Finance::NPQ::ParticipantEligibleAndPayableAggregator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:statement) { create(:npq_statement, cpd_lead_provider: cpd_lead_provider) }
  let(:another_statement) { create(:npq_statement, cpd_lead_provider: cpd_lead_provider) }
  let!(:declaration) { create(:npq_participant_declaration, statement: another_statement, state: "payable", cpd_lead_provider: cpd_lead_provider) }

  subject do
    described_class.new(statement: statement, course_identifier: declaration.course_identifier)
  end

  describe "#call" do
    it "does not include assigned declarations" do
      expect(subject.call[:all]).to be_zero
    end
  end
end
