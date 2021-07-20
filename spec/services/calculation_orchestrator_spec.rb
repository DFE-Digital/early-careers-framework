# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalculationOrchestrator do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:expected_result) do
    {
      service_fees: [
        {
          service_fee_monthly: 22_288.0,
          service_fee_per_participant: 323.0,
          service_fee_total: 646_349.0,
        },
        {
          service_fee_monthly: 0.0,
          service_fee_per_participant: 392.0,
          service_fee_total: 0.0,
        },
        {
          service_fee_monthly: 0.0,
          service_fee_per_participant: 386.0,
          service_fee_total: 0.0,
        },
      ],
      output_payments: [
        {
          per_participant: 597.0,
          started: {
            retained_participants: 10,
            per_participant: 119.0,
            subtotal: 1194.0,
          },
        },
        {
          per_participant: 587.0,
          started: {
            retained_participants: 0,
            per_participant: 117.0,
            subtotal: 0.0,
          },
        },
        {
          per_participant: 580.0,
          started: {
            retained_participants: 0,
            per_participant: 116.0,
            subtotal: 0.0,
          },
        },
      ],
      uplift: {
        per_participant: 100.0,
        sub_total: 1000.0,
      },
    }
  end

  context ".call" do
    context "when uplift flags were set" do
      let(:with_uplift) { :sparsity_uplift }

      before do
        create_list(:participant_declaration, 10, with_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      context "when only sparsity_uplift flag was set" do
        it "returns the total calculation" do
          expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
        end
      end

      context "when only pupil_premium_uplift flag was set" do
        let(:with_uplift) { :pupil_premium_uplift }

        it "returns the total calculation" do
          expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
        end
      end

      context "when both sparsity_uplift and pupil_premium_uplift flags were set" do
        let(:with_uplift) { :uplift_flags }

        it "returns the total calculation" do
          expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
        end
      end
    end

    context "when no uplift flags were set" do
      before do
        create_list(:participant_declaration, 10, lead_provider: call_off_contract.lead_provider)
        expected_result.tap { |hash| hash[:uplift][:sub_total] = 0.0 }
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
      end
    end

    context "when only mentor profile declaration records available" do
      before do
        create_list(:participant_declaration, 10, :only_mentor_profile, lead_provider: call_off_contract.lead_provider)
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
      end
    end

    context "when only ect profile declaration records available" do
      before do
        create_list(:participant_declaration, 10, :only_ect_profile, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
      end
    end

    context "when both mentor profile and ect profile declaration records available" do
      before do
        create_list(:participant_declaration, 5, :only_ect_profile, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        create_list(:participant_declaration, 5, :only_ect_profile, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(expected_result)
      end
    end
  end
end
