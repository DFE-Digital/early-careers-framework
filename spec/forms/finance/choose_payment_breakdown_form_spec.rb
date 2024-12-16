# frozen_string_literal: true

RSpec.describe Finance::ChoosePaymentBreakdownForm, type: :model do
  let(:form) { described_class.new({}) }

  describe "#ecf_providers" do
    subject { form.ecf_providers }

    before { create_list(:lead_provider, 3) }

    it { is_expected.to eq(LeadProvider.name_order) }
  end
end
