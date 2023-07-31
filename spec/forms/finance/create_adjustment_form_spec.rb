# frozen_string_literal: true

RSpec.describe Finance::CreateAdjustmentForm, type: :model do
  let(:statement) { create :ecf_statement }
  let(:params) { { session: {}, statement: } }

  describe "add new adjustment" do
    context "step through and confirm" do
      it "creates adjustment" do
        form = described_class.new(params)
        form.assign_attributes(
          payment_type: "Payment 1",
          form_step: "step1",
        )
        expect(form.save_step).to eql(true)
        expect(Finance::Adjustment.count).to eql(0)

        form = described_class.new(params)
        form.assign_attributes(
          amount: 100.00,
          form_step: "step2",
        )
        expect(form.save_step).to eql(true)
        expect(Finance::Adjustment.count).to eql(0)

        form = described_class.new(params)
        form.assign_attributes(
          payment_type: "Payment 1",
          amount: 100.00,
          form_step: "confirm",
        )
        expect(form.save_step).to eql(true)
        expect(Finance::Adjustment.count).to eql(1)

        adjustment = Finance::Adjustment.first
        expect(adjustment.payment_type).to eql("Payment 1")
        expect(adjustment.amount).to eql(100.0)
      end
    end

    context "step: step1" do
      it "validates payment_type" do
        form = described_class.new(params)
        form.assign_attributes(
          payment_type: "",
          amount: 0.0,
          form_step: "step1",
        )
        expect(form.save_step).to eql(false)
        expect(Finance::Adjustment.count).to eql(0)
        expect(form.errors.full_messages).to eql(["Payment type Enter a name for the adjustment you want to add"])
      end
    end

    context "step: step2" do
      it "validates amount" do
        form = described_class.new(params)
        form.assign_attributes(
          payment_type: "",
          amount: 0.0,
          form_step: "step2",
        )
        expect(form.save_step).to eql(false)
        expect(Finance::Adjustment.count).to eql(0)
        expect(form.errors.full_messages).to eql(["Amount Enter the amount of money that needs to be paid"])
      end
    end

    context "step: confirm" do
      it "validates payment_type and amount" do
        form = described_class.new(params)
        form.assign_attributes(
          payment_type: "",
          amount: 0.0,
          form_step: "confirm",
        )
        expect(form.save_step).to eql(false)
        expect(Finance::Adjustment.count).to eql(0)
        expect(form.errors.full_messages.sort).to eql([
          "Amount Enter the amount of money that needs to be paid",
          "Payment type Enter a name for the adjustment you want to add",
        ])
      end
    end
  end

  describe ".redirect_to" do
    let(:params) { { session: {}, statement:, form_step: } }
    subject(:form) { described_class.new(params) }

    context "step: step1" do
      let(:form_step) { "step1" }

      it "redirects to step2" do
        expect(form.redirect_to).to eql(new_finance_statement_adjustment_path(statement, form_step: "step2"))
      end
    end

    context "step: step2" do
      let(:form_step) { "step2" }

      it "redirects to confirm" do
        expect(form.redirect_to).to eql(new_finance_statement_adjustment_path(statement, form_step: "confirm"))
      end
    end

    context "step: confirm" do
      let(:form_step) { "confirm" }

      it "redirects to adjustments page" do
        expect(form.redirect_to).to eql(finance_statement_adjustments_path(statement, added_new: true))
      end
    end
  end

  describe ".back_link" do
    let(:params) { { session: {}, statement:, form_step: } }
    subject(:form) { described_class.new(params) }

    context "step: step1" do
      let(:form_step) { "step1" }

      context "ECF statement" do
        let(:statement) { create :ecf_statement }

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

    context "step: step2" do
      let(:form_step) { "step2" }

      it "redirects to step1" do
        expect(form.back_link).to eql(new_finance_statement_adjustment_path(statement, form_step: "step1"))
      end
    end

    context "step: confirm" do
      let(:form_step) { "confirm" }

      it "redirects to step2" do
        expect(form.back_link).to eql(new_finance_statement_adjustment_path(statement, form_step: "step2"))
      end
    end
  end
end
