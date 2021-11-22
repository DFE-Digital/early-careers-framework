# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::CalculationOrchestrator do
  let(:cpd_lead_provider) { create :cpd_lead_provider, :with_npq_lead_provider, name: "Contract Test Lead Provider" }
  let(:contract) { create(:npq_contract, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
  let(:npq_course) { create(:npq_course, identifier: contract.course_identifier) }
  let(:breakdown_summary) do
    {
      name: cpd_lead_provider.npq_lead_provider.name,
      recruitment_target: contract.recruitment_target,
      participants: 9,
      total_participants_paid: 5,
      total_participants_not_paid: 4,
      version: contract.version,
      course_identifier: contract.course_identifier,
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

  subject(:run_calculation) do
    described_class.call(
      cpd_lead_provider: cpd_lead_provider,
      contract: contract,
      interval: Finance::Invoice.find_by_name("current").interval,
    )
  end

  context ".call" do
    context "normal operation" do
      before do
        FactoryBot.with_options cpd_lead_provider: cpd_lead_provider, course_identifier: contract.course_identifier do |factory|
          factory.create_list(:npq_participant_declaration, 3, :eligible)
          factory.create_list(:npq_participant_declaration, 2, :payable)
          factory.create_list(:npq_participant_declaration, 4, :submitted)
          factory.create_list(:npq_participant_declaration, 3, :voided)
          factory.create_list(:npq_participant_declaration, 7, :paid)
        end
      end

      it "returns the total calculation" do
        expect(run_calculation[:breakdown_summary]).to eq(breakdown_summary)
        expect(run_calculation[:service_fees][:monthly]).to be_within(0.001).of(service_fees[:monthly])
        expect(run_calculation[:output_payments]).to eq(output_payments)
      end

      it "ignores non-eligible declarations" do
        create_list(:npq_participant_declaration, 5, :submitted, cpd_lead_provider: cpd_lead_provider, course_identifier: "other-course")
        expect(run_calculation[:breakdown_summary]).to eq(breakdown_summary)
        expect(run_calculation[:service_fees][:monthly]).to be_within(0.001).of(service_fees[:monthly])
        expect(run_calculation[:output_payments]).to eq(output_payments)
      end
    end
  end
end
