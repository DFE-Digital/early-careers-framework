# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalculationOrchestrator do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:headings) {
    {
      declaration: :started,
      ects: 5,
      mentors: 5,
      name: "Lead Provider",
      participants: 10,
      target: 2000,
    }
  }
  let(:ect_focussed_headings) {
    headings.merge({ects: 10, mentors: 0})
  }
  let(:mentor_focussed_headings) {
    headings.merge({ects: 0, mentors: 10})
  }
  let(:service_fees) {
    [
      {
        band: "A",
        participants: 2000,
        monthly: 22_288.0,
        per_participant: 323.0,
      },
      {
        band: "B",
        participants: 0,
        monthly: 0.0,
        per_participant: 392.0,
      },
      {
        band: "C",
        participants: 0,
        monthly: 0.0,
        per_participant: 386.0,
      },
    ]
  }
  let(:output_payments) {
    [
      {
        band: "A",
        participants: 10,
        per_participant: 119.0,
        subtotal: 1194.0,
      },
      {
        band: "B",
        participants: 0,
        per_participant: 117.0,
        subtotal: 0.0,
      },
      {
        band: "C",
        participants: 0,
        per_participant: 116.0,
        subtotal: 0.0,
      },
    ]
  }
  let(:other_fees) {
    {
      uplift: {
        participants: 10,
        per_participant: 100.0,
        subtotal: 1000.0,
      }
    }
  }

  let(:normal_outcome) {
    {
      headings: headings,
      service_fees: service_fees,
      output_payments: output_payments,
      other_fees: other_fees
    }
  }
  let(:mentor_outcome) {
    normal_outcome.merge(headings: mentor_focussed_headings)
  }
  let(:ect_outcome) {
    normal_outcome.merge(headings: ect_focussed_headings)
  }

  context ".call" do
    context "when uplift flags were set" do
      let(:with_uplift) { :sparsity_uplift }

      before do
        create_list(:ect_participant_declaration, 5, with_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        create_list(:mentor_participant_declaration, 5, with_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      context "when only sparsity_uplift flag was set" do
        it "returns the total calculation" do
          expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider,
                                      event_type: :started)).to eq(normal_outcome)
        end
      end

      context "when only pupil_premium_uplift flag was set" do
        let(:with_uplift) { :pupil_premium_uplift }

        it "returns the total calculation" do
          expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(normal_outcome)
        end
      end

      context "when both sparsity_uplift and pupil_premium_uplift flags were set" do
        let(:with_uplift) { :uplift_flags }

        it "returns the total calculation" do
          expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(normal_outcome)
        end
      end
    end

    context "when no uplift flags were set" do
      before do
        create_list(:ect_participant_declaration, 5, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, uplift: false)
        create_list(:mentor_participant_declaration, 5, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, uplift: false)
        normal_outcome[:other_fees][:uplift].tap do |hash|
          hash[:participants]=0
          hash[:subtotal]=0
        end
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(normal_outcome)
      end
    end

    context "when only mentor profile declaration records available" do
      before do
        create_list(:mentor_participant_declaration, 10, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(mentor_outcome)
      end
    end

    context "when only ect profile declaration records available" do
      before do
        create_list(:ect_participant_declaration, 10, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(ect_outcome)
      end
    end

    context "when both mentor profile and ect profile declaration records available" do
      before do
        create_list(:ect_participant_declaration, 5, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        create_list(:mentor_participant_declaration, 5, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
      end

      it "returns the total calculation" do
        expect(described_class.call(contract: call_off_contract, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, event_type: :started)).to eq(normal_outcome)
      end
    end
  end
end
