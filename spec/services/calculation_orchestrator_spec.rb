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
    context "when only sparsity_uplift flag was set" do
      before do
        10.times do
          participant_declaration = create(:participant_declaration, lead_provider: call_off_contract.lead_provider)
          create(:profile_declaration, participant_declaration: participant_declaration, declarable: create(:early_career_teacher_profile_declaration, :sparsity_uplift))
        end
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, lead_provider: call_off_contract.lead_provider, event_type: :started)).to eq(expected_result)
      end
    end

    context "when only pupil_premium_uplift flag was set" do
      before do
        10.times do
          participant_declaration = create(:participant_declaration, lead_provider: call_off_contract.lead_provider)
          create(:profile_declaration, participant_declaration: participant_declaration, declarable: create(:early_career_teacher_profile_declaration, :pupil_premium_uplift))
        end
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, lead_provider: call_off_contract.lead_provider, event_type: :started)).to eq(expected_result)
      end
    end

    context "when both sparsity_uplift and pupil_premium_uplift flags were set" do
      before do
        10.times do
          participant_declaration = create(:participant_declaration, lead_provider: call_off_contract.lead_provider)
          create(:profile_declaration, participant_declaration: participant_declaration, declarable: create(:early_career_teacher_profile_declaration, :uplift_flags))
        end
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, lead_provider: call_off_contract.lead_provider, event_type: :started)).to eq(expected_result)
      end
    end

    context "when no uplift flags were set" do
      before do
        create_list(:participant_declaration, 10, lead_provider: call_off_contract.lead_provider)
        expected_result.tap { |hash| hash[:uplift][:sub_total] = 0.0 }
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, lead_provider: call_off_contract.lead_provider, event_type: :started)).to eq(expected_result)
      end
    end
  end
end
