# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::StatementCalculator do
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }

  let!(:npq_course) { create(:npq_leadship_course, identifier: "npq-leading-teaching") }

  let!(:contract) { create(:npq_contract, npq_lead_provider:) }

  let(:statement) { create(:npq_statement, cpd_lead_provider:) }

  subject { described_class.new(statement:) }

  describe "#total_payment" do
    let(:default_total) { BigDecimal("0.1212631578947368421052631578947368421064e4") }

    context "when there is a positive reconcile_amount" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "increases total" do
        expect(subject.total_payment).to eql(default_total + 1234)
      end
    end

    context "when there is a negative reconcile_amount" do
      before do
        statement.update!(reconcile_amount: -1234)
      end

      it "descreases the total" do
        expect(subject.total_payment).to eql(default_total - 1234)
      end
    end
  end

  describe "#overall_vat" do
    let(:default_total) { BigDecimal("0.1212631578947368421052631578947368421064e4") }

    context "when reconcile_amount is present and VAT is applicable" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "affects the amount to reconcile by" do
        expect(subject.overall_vat).to eql((default_total + 1234) * 0.2)
      end
    end
  end
end
