# frozen_string_literal: true

RSpec.describe Finance::CreatePaymentAuthorisationForm, type: :model do
  let(:statement) { create :ecf_statement }
  let(:params) { { statement:, checks_done: true } }

  subject(:form) { described_class.new(params) }

  describe "#valid?" do
    context "checks done true" do
      let(:params) { { statement:, checks_done: true } }

      it "is valid" do
        expect(form.valid?).to eql(true)
      end
    end

    context "checks done false" do
      let(:params) { { statement:, checks_done: false } }

      it "is valid" do
        expect(form.valid?).to eql(false)
      end
    end
  end

  describe "#save_form" do
    it "marks statement as paid" do
      expect { form.save_form }.to change { statement.reload.marked_as_paid_at }
    end

    it "calls the correct service class" do
      expect(Finance::Statements::MarkAsPaidJob).to receive(:perform_later).with(statement_id: statement.id)

      form.save_form
    end
  end

  describe "#back_link" do
    context "ECF statement" do
      it "redirects to ECF statement page" do
        expect(form.back_link).to eql(finance_ecf_payment_breakdown_statement_path(statement.lead_provider, statement))
      end
    end

    context "NPQ statement" do
      let(:statement) { create :npq_statement }

      it "redirects to NPQ statement page" do
        expect(form.back_link).to eql(finance_npq_lead_provider_statement_path(statement.npq_lead_provider, statement))
      end
    end
  end
end
