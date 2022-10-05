# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::Finance::Statements::Index do
  describe "#statements" do
    let(:cohort_2021) { create(:cohort, :current) }
    let(:cohort_2022) { create(:cohort, :next) }

    let(:cpd_lead_provider) { create(:cpd_lead_provider) }

    let!(:ecf_statement_cohort_another_lead_provider) { create(:ecf_statement, :output_fee, cohort: cohort_2022) }
    let!(:ecf_statement_without_output) do
      create(
        :ecf_statement,
        output_fee: false,
        cpd_lead_provider:,
        cohort: cohort_2022,
        payment_date: 4.days.ago,
      )
    end
    let!(:ecf_statement_cohort_2022) do
      create(
        :ecf_statement,
        :output_fee,
        cpd_lead_provider:,
        cohort: cohort_2022,
        payment_date: 4.days.ago,
      )
    end
    let!(:ecf_statement_cohort_2021) do
      create(
        :ecf_statement,
        :output_fee,
        cpd_lead_provider:,
        cohort: cohort_2021,
        payment_date: 3.days.ago,
      )
    end
    let!(:npq_statement_cohort_2022) do
      create(
        :npq_statement,
        :output_fee,
        cpd_lead_provider:,
        cohort: cohort_2022,
        payment_date: 2.days.ago,
      )
    end
    let!(:npq_statement_cohort_2021) do
      create(
        :npq_statement,
        :output_fee,
        cpd_lead_provider:,
        cohort: cohort_2021,
        payment_date: 1.day.ago,
      )
    end

    let(:params) { {} }

    subject { described_class.new(cpd_lead_provider:, params:) }

    it "returns all output statements for the cpd provider ordered by payment_date" do
      expect(subject.statements).to eq([
        ecf_statement_cohort_2022,
        ecf_statement_cohort_2021,
        npq_statement_cohort_2022,
        npq_statement_cohort_2021,
      ])
    end

    context "with correct cohort filter" do
      let(:params) { { filter: { cohort: "2021" } } }

      it "returns all output statements for the specific cohort" do
        expect(subject.statements).to eq([
          ecf_statement_cohort_2021,
          npq_statement_cohort_2021,
        ])
      end
    end

    context "with multiple cohort filter" do
      let(:params) { { filter: { cohort: "2021,2022" } } }

      it "returns all output statements for the specific cohort" do
        expect(subject.statements).to eq([
          ecf_statement_cohort_2022,
          ecf_statement_cohort_2021,
          npq_statement_cohort_2022,
          npq_statement_cohort_2021,
        ])
      end
    end

    context "with incorrect cohort filter" do
      let(:params) { { filter: { cohort: "2017" } } }

      it "returns no statements" do
        expect(subject.statements).to be_empty
      end
    end

    context "with ecf type filter" do
      let(:params) { { filter: { type: "ecf" } } }

      it "returns all output ecf statements" do
        expect(subject.statements).to eq([
          ecf_statement_cohort_2022,
          ecf_statement_cohort_2021,
        ])
      end
    end

    context "with npq type filter" do
      let(:params) { { filter: { type: "npq" } } }

      it "returns all output npq statements" do
        expect(subject.statements).to eq([
          npq_statement_cohort_2022,
          npq_statement_cohort_2021,
        ])
      end

      context "with incorrect type filter" do
        let(:params) { { filter: { type: "does-not-exist" } } }

        it "returns no statements" do
          expect(subject.statements).to be_empty
        end
      end

      context "with an ecf and cohort filter" do
        let(:params) { { filter: { type: "ecf", cohort: "2021" } } }

        it "returns ecf output statement that belongs to the cohort" do
          expect(subject.statements).to contain_exactly(ecf_statement_cohort_2021)
        end
      end
    end
  end
end
