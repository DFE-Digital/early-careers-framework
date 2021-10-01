# frozen_string_literal: true

describe FinanceHelper do
  describe "#total_payment" do
    let!(:lead_provider) { create(:lead_provider) }
    let!(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
    let!(:contract) { create(:call_off_contract, lead_provider: cpd_lead_provider.lead_provider) }

    let(:breakdown) do
      CalculationOrchestrator.call(
        cpd_lead_provider: cpd_lead_provider,
        contract: cpd_lead_provider.lead_provider.call_off_contract,
        event_type: :started,
      )
    end

    it "returns the total payment for the breakddown" do
      expect(helper.total_payment(breakdown).to_i).to eq(22_287)
    end

    it "returns the total VAT for the breakddown" do
      expect(helper.total_vat(breakdown).to_i).to eq(4_457)
    end
  end
end
