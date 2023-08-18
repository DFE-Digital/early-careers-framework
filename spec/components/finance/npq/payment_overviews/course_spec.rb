# frozen_string_literal: true

RSpec.describe Finance::NPQ::PaymentOverviews::Course, type: :component do
  let(:statement) { create(:npq_statement) }
  let!(:npq_leadership_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
  let(:contract) { create(:npq_contract, :npq_senior_leadership, monthly_service_fee:) }
  let(:component) { described_class.new statement:, contract: }

  subject { render_inline(component) }

  context "monthly service fees" do
    context "set to nil" do
      let(:monthly_service_fee) { nil }

      it "renders service fees" do
        is_expected.to have_content("Service fee")
      end
    end

    context "set to 99.0" do
      let(:monthly_service_fee) { 99.0 }

      it "renders service fees" do
        is_expected.to have_content("Service fee")
      end
    end

    context "set to 0.0" do
      let(:monthly_service_fee) { 0.0 }

      it "should not render service fees" do
        is_expected.to_not have_content("Service fee")
      end
    end
  end
end
