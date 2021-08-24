# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalculationOrchestrator do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:breakdown_summary) do
    {
      declaration: :started,
      ects: 5,
      mentors: 5,
      name: "Lead Provider",
      participants: 10,
      target: 2000,
    }
  end
  let(:ect_focussed_headings) do
    breakdown_summary.merge({ ects: 10, mentors: 0 })
  end
  let(:mentor_focussed_headings) do
    breakdown_summary.merge({ ects: 0, mentors: 10 })
  end
  let(:service_fees) do
    [
      {
        band: "A",
        participants: 2000,
        monthly: 22_287.90,
        per_participant: 323.17,
      },
      {
        band: "B",
        participants: 0,
        monthly: 0.0,
        per_participant: 391.60,
      },
      {
        band: "C",
        participants: 0,
        monthly: 0.0,
        per_participant: 386.40,
      },
    ]
  end
  let(:output_payments) do
    [
      {
        band: "A",
        participants: 10,
        per_participant: 119.40,
        subtotal: 1194.0,
      },
      {
        band: "B",
        participants: 0,
        per_participant: 117.48,
        subtotal: 0.0,
      },
      {
        band: "C",
        participants: 0,
        per_participant: 115.92,
        subtotal: 0.0,
      },
    ]
  end
  let(:other_fees) do
    {
      uplift: {
        participants: 10,
        per_participant: 100.0,
        subtotal: 1000.0,
      },
    }
  end

  let(:normal_outcome) do
    {
      breakdown_summary: breakdown_summary,
      service_fees: service_fees,
      output_payments: output_payments,
      other_fees: other_fees,
    }
  end
  let(:mentor_outcome) do
    normal_outcome.merge(breakdown_summary: mentor_focussed_headings)
  end
  let(:ect_outcome) do
    normal_outcome.merge(breakdown_summary: ect_focussed_headings)
  end

  def set_precision(hash, rounding)
    with_rounding(hash) { |sub_hash, k, v| sub_hash[k] = v.round(rounding) }
  end

  def with_rounding(hash, &blk)
    hash.each do |k, v|
      yield(hash, k, v) if v.is_a?(BigDecimal)
      case hash[k]
      when Hash
        with_rounding(hash[k], &blk)
      when Array
        # I know this is a hash, if it wasn't this wouldn't work and you'd have to handle the values more elegantly
        hash[k].each do |service_fee_hash|
          with_rounding(service_fee_hash, &blk)
        end
      else
        next
      end
    end
  end

  context ".call" do
    context "when uplift flags were set" do
      let(:with_uplift) { :sparsity_uplift }

      before do
        create_list(:ect_participant_declaration, 5, with_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
        create_list(:mentor_participant_declaration, 5, with_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
      end

      context "when only sparsity_uplift flag was set" do
        it "returns the total calculation" do
          expect(run_calculation).to eq(normal_outcome)
        end
      end

      context "when only pupil_premium_uplift flag was set" do
        let(:with_uplift) { :pupil_premium_uplift }

        it "returns the total calculation" do
          expect(run_calculation).to eq(normal_outcome)
        end
      end

      context "when both sparsity_uplift and pupil_premium_uplift flags were set" do
        let(:with_uplift) { :uplift_flags }

        it "returns the total calculation" do
          expect(run_calculation).to eq(normal_outcome)
        end
      end
    end

    context "when no uplift flags were set" do
      before do
        create_list(:ect_participant_declaration, 5, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
        create_list(:mentor_participant_declaration, 5, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
        normal_outcome[:other_fees][:uplift].tap do |hash|
          hash[:participants] = 0
          hash[:subtotal] = 0
        end
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(normal_outcome)
      end

      it "ignores non-payable declarations" do
        create_list(:ect_participant_declaration, 5, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: false)
        expect(run_calculation).to eq(normal_outcome)
      end
    end

    context "when only mentor profile declaration records available" do
      before do
        create_list(:mentor_participant_declaration, 10, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(mentor_outcome)
      end
    end

    context "when only ect profile declaration records available" do
      before do
        create_list(:ect_participant_declaration, 10, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(ect_outcome)
      end
    end

    context "when both mentor profile and ect profile declaration records available" do
      before do
        create_list(:ect_participant_declaration, 5, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
        create_list(:mentor_participant_declaration, 5, :sparsity_uplift, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, payable: true)
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(normal_outcome)
      end
    end
  end

private

  def run_calculation
    set_precision(
      described_class.call(
        contract: call_off_contract,
        cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider,
        event_type: :started,
      ),
      2,
    )
  end
end
