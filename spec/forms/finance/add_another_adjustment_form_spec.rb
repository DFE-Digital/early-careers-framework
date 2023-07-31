# frozen_string_literal: true

RSpec.describe Finance::AddAnotherAdjustmentForm, type: :model do
  let(:statement) { create :ecf_statement }
  let(:params) { { statement:, add_another: "yes" } }
  subject(:form) { described_class.new(params) }

  describe ".valid?" do
    context "select yes" do
      let(:params) { { statement:, add_another: "yes" } }

      it "is valid" do
        expect(form.valid?).to eql(true)
      end

      it "redirects to new action" do
        expect(form.redirect_to).to eql(new_finance_statement_adjustment_path(statement))
      end
    end

    context "ECF: select no" do
      let(:params) { { statement:, add_another: "no" } }

      it "is valid" do
        expect(form.valid?).to eql(true)
      end

      it "redirects to ECF statement page" do
        expect(form.redirect_to).to eql(finance_ecf_payment_breakdown_statement_path(statement.lead_provider, statement))
      end
    end

    context "NPQ: select no" do
      let(:statement) { create :npq_statement }
      let(:params) { { statement:, add_another: "no" } }

      it "is valid" do
        expect(form.valid?).to eql(true)
      end

      it "redirects to NPQ statement page" do
        expect(form.redirect_to).to eql(finance_npq_lead_provider_statement_path(statement.npq_lead_provider, statement))
      end
    end

    context "no choice" do
      let(:params) { { statement:, add_another: "" } }

      it "is not valid" do
        expect(form.valid?).to eql(false)
        expect(form.errors.full_messages).to eql(["Add another Select if you need to add another adjustment"])
      end
    end
  end
end
