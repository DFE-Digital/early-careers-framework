# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::Finance::StatementsQuery do
  describe "#statements" do
    let(:current_cohort) { Cohort.current || create(:cohort, :current) }
    let(:next_cohort) { Cohort.next || create(:cohort, :next) }

    let(:cpd_lead_provider) { create(:cpd_lead_provider) }

    let!(:ecf_statement_cohort_another_lead_provider) { create(:ecf_statement, :output_fee, cohort: next_cohort) }
    let!(:ecf_statement_without_output) do
      create(
        :ecf_statement,
        output_fee: false,
        cpd_lead_provider:,
        cohort: next_cohort,
        payment_date: 4.days.ago,
      )
    end
    let!(:ecf_statement_next_cohort) do
      create(
        :ecf_statement,
        :output_fee,
        cpd_lead_provider:,
        cohort: next_cohort,
        payment_date: 4.days.ago,
      )
    end

    let(:params) { {} }

    subject { described_class.new(cpd_lead_provider:, params:) }

    describe "#statements" do
      let!(:ecf_statement_current_cohort) do
        create(
          :ecf_statement,
          :output_fee,
          cpd_lead_provider:,
          cohort: current_cohort,
          payment_date: 3.days.ago,
        )
      end
      let!(:npq_statement_next_cohort) do
        create(
          :npq_statement,
          :output_fee,
          cpd_lead_provider:,
          cohort: next_cohort,
          payment_date: 2.days.ago,
        )
      end
      let!(:npq_statement_current_cohort) do
        create(
          :npq_statement,
          :output_fee,
          cpd_lead_provider:,
          cohort: current_cohort,
          payment_date: 1.day.ago,
        )
      end

      it "returns all output statements for the cpd provider ordered by payment_date" do
        expect(subject.statements).to eq([
          ecf_statement_next_cohort,
          ecf_statement_current_cohort,
          npq_statement_next_cohort,
          npq_statement_current_cohort,
        ])
      end

      context "with correct cohort filter" do
        let(:params) { { filter: { cohort: current_cohort.display_name } } }

        it "returns all output statements for the specific cohort" do
          expect(subject.statements).to eq([
            ecf_statement_current_cohort,
            npq_statement_current_cohort,
          ])
        end
      end

      context "with multiple cohort filter" do
        let(:params) { { filter: { cohort: [current_cohort.start_year, next_cohort.start_year].join(",") } } }

        it "returns all output statements for the specific cohort" do
          expect(subject.statements).to eq([
            ecf_statement_next_cohort,
            ecf_statement_current_cohort,
            npq_statement_next_cohort,
            npq_statement_current_cohort,
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

        it "returns all ecf statements" do
          expect(subject.statements).to eq([
            ecf_statement_next_cohort,
            ecf_statement_current_cohort,
          ])
        end
      end

      context "with npq type filter" do
        let(:params) { { filter: { type: "npq" } } }

        it "returns all npq statements" do
          expect(subject.statements).to eq([
            npq_statement_next_cohort,
            npq_statement_current_cohort,
          ])
        end

        context "with incorrect type filter" do
          let(:params) { { filter: { type: "does-not-exist" } } }

          it "returns no statements" do
            expect(subject.statements).to be_empty
          end
        end

        context "with an ecf and cohort filter" do
          let(:params) { { filter: { type: "ecf", cohort: current_cohort.display_name } } }

          it "returns ecf statement that belongs to the cohort" do
            expect(subject.statements).to contain_exactly(ecf_statement_current_cohort)
          end
        end
      end
    end

    describe "#statement" do
      context "when statement id belongs to CPD lead provider" do
        let(:params) { { id: ecf_statement_next_cohort.id } }

        it "returns the finance statement with the id" do
          expect(subject.statement).to eq(ecf_statement_next_cohort)
        end
      end

      context "when statement id belongs to another CPD lead provider" do
        let(:params) { { id: ecf_statement_cohort_another_lead_provider.id } }

        it "does not return the finance statement" do
          expect { subject.statement }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with non-existing id" do
        let(:params) { { id: "does-not-exist" } }

        it "does not return the finance statement" do
          expect { subject.statement }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no params id" do
        let(:params) { {} }

        it "does not return the finance statement" do
          expect { subject.statement }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
