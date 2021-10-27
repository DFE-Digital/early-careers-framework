# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::CalculationOrchestrator do
  let(:cpd_lead_provider) { create :cpd_lead_provider, :with_npq_lead_provider, name: "Contract Test Lead Provider" }
  let(:contract) { create(:npq_contract, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
  let(:breakdown_summary) do
    {
      declaration: :started,
      participants: 5,
      participants_not_paid: 0,
      recruitment_target: 72,
    }
  end
  let(:service_fees) do
    {
      monthly: 72 * 0.4 * 800 / 19,
    }
  end
  let(:output_payments) do
    {
      participants: 5,
      per_participant: 800 * 0.6 / 3,
      subtotal: 5 * 800 * 0.6 / 3,
    }
  end

  context ".call" do
    context "normal operation" do
      before do
        create_list(:npq_participant_declaration, 5, :eligible, cpd_lead_provider: cpd_lead_provider)
      end

      it "returns the total calculation" do
        returned_hash = run_calculation
        expect(returned_hash[:breakdown_summary].except(:name)).to eq(breakdown_summary)
        expect(returned_hash[:service_fees][:monthly]).to be_within(0.001).of(service_fees[:monthly])
        expect(returned_hash[:output_payments]).to eq(output_payments)
      end

      it "ignores non-eligible declarations" do
        create_list(:npq_participant_declaration, 5, :submitted, cpd_lead_provider: cpd_lead_provider)
        returned_hash = run_calculation
        expect(returned_hash[:breakdown_summary].except(:name)).to eq(breakdown_summary.merge(participants_not_paid: 5))
        expect(returned_hash[:service_fees][:monthly]).to be_within(0.001).of(service_fees[:monthly])
        expect(returned_hash[:output_payments]).to eq(output_payments)
      end
    end
  end

private

  def run_calculation(aggregator: Finance::NPQ::ParticipantEligibleAggregator)
    described_class.call(
      aggregator: aggregator,
      contract: contract,
      cpd_lead_provider: contract.npq_lead_provider.cpd_lead_provider,
      event_type: :started,
    )
  end
end
