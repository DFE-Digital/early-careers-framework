# frozen_string_literal: true

require "rails_helper"

module Finance
  module ECF
    class DummyAggregator
      def initialize(*); end

      def call(*)
        {
          all: 10_000,
          uplift: 10_000,
          ects: 5_000,
          mentors: 5_000,
          previous_participants: 0,
        }
      end
    end
  end
end

RSpec.describe Finance::ECF::CalculationOrchestrator do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:breakdown_summary) do
    {
      ects: 5,
      mentors: 5,
      name: "Lead Provider",
      participants: 10,
      recruitment_target: 2000,
      revised_target: nil,
      not_yet_included_participants: nil,
    }
  end
  let(:service_fees) do
    [
      {
        band: 0,
        participants: 2000,
        monthly: 22_287.90,
        per_participant: 323.17,
      },
      {
        band: 1,
        participants: 0,
        monthly: 0.0,
        per_participant: 391.60,
      },
      {
        band: 2,
        participants: 0,
        monthly: 0.0,
        per_participant: 386.40,
      },
    ]
  end
  let(:output_payments) do
    [
      {
        band: 0,
        participants: 10,
        per_participant: 119.40,
        subtotal: 1194.0,
      },
      {
        band: 1,
        participants: 0,
        per_participant: 117.48,
        subtotal: 0.0,
      },
      {
        band: 2,
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
  let(:capped_uplift) do
    {
      uplift: {
        participants: 10_000,
        per_participant: 100.0,
        subtotal: 99_500.0,
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

  let(:statement) do
    create(:ecf_statement, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
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

  describe "#call" do
    context "when uplift flags were set" do
      let(:with_uplift) { :sparsity_uplift }

      before do
        create_list(:ect_participant_declaration, 5, with_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
        create_list(:mentor_participant_declaration, 5, with_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
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

      context "when excessive uplift records are passed" do
        it "limits the amount to the capped level" do
          results = run_calculation(aggregator: ::Finance::ECF::DummyAggregator.new)
          expect(results[:other_fees]).to eq(capped_uplift)
        end
      end
    end

    context "when no uplift flags were set" do
      before do
        create_list(:ect_participant_declaration, 5, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
        create_list(:mentor_participant_declaration, 5, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
        normal_outcome[:other_fees][:uplift].tap do |hash|
          hash[:participants] = 0
          hash[:subtotal] = 0
        end
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(normal_outcome)
      end
    end

    context "when only mentor profile declaration records available" do
      let(:mentor_outcome) do
        normal_outcome.merge(
          breakdown_summary: breakdown_summary.merge({ ects: 0, mentors: 10 }),
        )
      end

      before do
        create_list(:mentor_participant_declaration, 10, :sparsity_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(mentor_outcome)
      end
    end

    context "when only ect profile declaration records available" do
      let(:ect_outcome) do
        normal_outcome.merge(
          breakdown_summary: breakdown_summary.merge({ ects: 10, mentors: 0 }),
        )
      end

      before do
        create_list(:ect_participant_declaration, 10, :sparsity_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(ect_outcome)
      end
    end

    context "when both mentor profile and ect profile declaration records available" do
      before do
        create_list(:ect_participant_declaration, 5, :sparsity_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
        create_list(:mentor_participant_declaration, 5, :sparsity_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
      end

      it "returns the total calculation" do
        expect(run_calculation).to eq(normal_outcome)
      end
    end

    context "when ineligible records available" do
      let(:ineligible_outcome) do
        normal_outcome.merge(
          breakdown_summary: breakdown_summary.merge({ ects: 10, mentors: 0, not_yet_included_participants: 10, participants: 10 }),
        )
      end

      before do
        create_list(:ect_participant_declaration, 10, :sparsity_uplift, :eligible, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
        create_list(:ect_participant_declaration, 10, :sparsity_uplift, :submitted, cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider, statement: statement)
      end

      it "returns the total calculation, and ineligible declarations are put in not_yet_included_participants field" do
        expect(run_calculation).to eq(ineligible_outcome)
      end
    end
  end

private

  def run_calculation(aggregator: Finance::ECF::ParticipantAggregator.new(statement: statement))
    set_precision(
      described_class.new(
        calculator: PaymentCalculator::ECF::PaymentCalculation,
        aggregator: aggregator,
        contract: call_off_contract,
        statement: statement,
      ).call(event_type: :started),
      2,
    )
  end
end
