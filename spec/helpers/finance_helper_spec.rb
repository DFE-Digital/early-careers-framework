# frozen_string_literal: true

describe FinanceHelper do
  describe "#total_payment" do
    let!(:lead_provider) { create(:lead_provider) }
    let!(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
    let!(:contract) { create(:call_off_contract, lead_provider: cpd_lead_provider.lead_provider) }

    let(:breakdown) do
      Finance::ECF::CalculationOrchestrator.call(
        cpd_lead_provider: cpd_lead_provider,
        contract: cpd_lead_provider.lead_provider.call_off_contract,
        event_type: :started,
      )
    end

    context "when lead provider is vat chargeable" do
      it "returns the total payment for the breakddown" do
        expect(helper.total_payment(breakdown).to_i).to eq(22_287)
      end

      it "returns the total VAT for the breakddown" do
        expect(helper.total_vat(breakdown, lead_provider).to_i).to eq(4_457)
      end
    end

    context "when lead provider is not vat chargeable" do
      let!(:lead_provider) { create(:lead_provider, vat_chargeable: false) }

      it "returns the total VAT for the breakddown" do
        expect(helper.total_vat(breakdown, lead_provider).to_i).to eq(0)
      end
    end
  end

  describe "#cutoff_date" do
    FinanceHelper::MILESTONE_DATES.each_with_index do |_date, index|
      next if index == 0

      milestone_begin_date = Date.parse(FinanceHelper::MILESTONE_DATES[index - 1])
      milestone_end_date = Date.parse(FinanceHelper::MILESTONE_DATES[index]) - 1.day
      random_date = rand(milestone_begin_date..milestone_end_date)

      [milestone_begin_date, milestone_end_date, random_date].each do |date|
        it "milestone date #{index} on the day #{date} returns correct cutoff date" do
          travel_to(date) do
            expect(cutoff_date).to eq(Date.parse(FinanceHelper::MILESTONE_DATES[index]).strftime("%-d %B %Y"))
          end
        end

        it "milestone date #{index} on the day #{date} for payable returns correct cutoff date" do
          travel_to(date) do
            expect(cutoff_date_payable).to eq(Date.parse(FinanceHelper::MILESTONE_DATES[index - 1]).strftime("%-d %B %Y"))
          end
        end
      end

      next if index < 2

      [milestone_begin_date, milestone_end_date, random_date].each do |date|
        it "milestone date #{index} on the day #{date} returns correct payment period" do
          travel_to(date) do
            expect(payment_period).to eq(FinanceHelper::MILESTONE_DATES[index - 1, 2])
          end
        end

        it "milestone date #{index} on the day #{date} for payable returns correct payment period" do
          travel_to(date) do
            expect(payment_period_payable).to eq(FinanceHelper::MILESTONE_DATES[index - 2, 2])
          end
        end
      end
    end
  end
end
