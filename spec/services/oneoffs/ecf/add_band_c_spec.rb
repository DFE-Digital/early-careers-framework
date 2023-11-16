# frozen_string_literal: true

RSpec.describe Oneoffs::ECF::AddBandC do
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:payment_date_range) { Date.new(2023, 10, 1)..Date.new(2023, 11, 30) }
  let(:band_c_params) do
    {
      min: 401,
      max: 455,
      per_participant: 100.0,
      output_payment_percentage: 60,
      service_fee_percentage: 40,
    }
  end
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider) }

  subject { described_class.new(cohort_year: cohort.start_year, cpd_lead_provider:, payment_date_range:, band_c_params:) }

  describe "#call" do
    let!(:ecf_statement1) { create(:ecf_statement, cohort:, contract_version: "0.0.1", payment_date: "2023-10-25", cpd_lead_provider:) }
    let!(:call_off_contract1) do
      contract = create(
        :call_off_contract,
        lead_provider: ecf_statement1.lead_provider,
        cohort: ecf_statement1.cohort,
        version: ecf_statement1.contract_version,
      )
      contract.participant_bands.destroy_all
      create(:participant_band, :band_a, call_off_contract: contract, per_participant: 200.0, min: 0, max: 200)
      create(:participant_band, :band_b, call_off_contract: contract, per_participant: 150.0, min: 201, max: 212)
      contract
    end

    let!(:ecf_statement2) { create(:ecf_statement, cohort:, contract_version: "0.0.4", payment_date: "2023-11-25", cpd_lead_provider: cpd_lead_provider2) }
    let!(:call_off_contract2) do
      contract = create(
        :call_off_contract,
        lead_provider: ecf_statement2.lead_provider,
        cohort: ecf_statement2.cohort,
        version: ecf_statement2.contract_version,
      )
      contract.participant_bands.destroy_all
      create(:participant_band, :band_a, call_off_contract: contract, per_participant: 200.0, min: 0, max: 200)
      create(:participant_band, :band_b, call_off_contract: contract, per_participant: 150.0, min: 201, max: 212)
      contract
    end

    let!(:ecf_statement3) { create(:ecf_statement, cohort:, contract_version: "0.0.7", payment_date: "2023-09-25", cpd_lead_provider:) }
    let!(:call_off_contract3) do
      contract = create(
        :call_off_contract,
        lead_provider: ecf_statement3.lead_provider,
        cohort: ecf_statement3.cohort,
        version: ecf_statement3.contract_version,
      )
      contract.participant_bands.destroy_all
      create(:participant_band, :band_a, call_off_contract: contract, per_participant: 200.0, min: 0, max: 200)
      create(:participant_band, :band_b, call_off_contract: contract, per_participant: 150.0, min: 201, max: 212)
      contract
    end

    it "should create new contract with Band C" do
      expect(Finance::Statement::ECF.count).to eql(3)
      expect(ecf_statement1.reload.contract_version).to eql("0.0.1")
      expect(ecf_statement2.reload.contract_version).to eql("0.0.4")
      expect(ecf_statement3.reload.contract_version).to eql("0.0.7")

      expect(CallOffContract.count).to eql(3)
      expect(call_off_contract1.reload.bands.count).to eql(2)
      expect(call_off_contract2.reload.bands.count).to eql(2)
      expect(call_off_contract3.reload.bands.count).to eql(2)

      subject.call

      expect(Finance::Statement::ECF.count).to eql(3)
      expect(ecf_statement1.reload.contract_version).to eql("0.0.2")
      expect(ecf_statement2.reload.contract_version).to eql("0.0.4")
      expect(ecf_statement3.reload.contract_version).to eql("0.0.7")

      expect(CallOffContract.count).to eql(3 + 1)
      expect(call_off_contract1.reload.bands.count).to eql(2)
      expect(call_off_contract2.reload.bands.count).to eql(2)
      expect(call_off_contract3.reload.bands.count).to eql(2)

      new_call_off_contract1 = CallOffContract.where(
        version: "0.0.2",
        cohort: call_off_contract1.cohort,
        lead_provider: call_off_contract1.lead_provider,
      ).first

      expect(new_call_off_contract1.uplift_target).to eql(call_off_contract1.uplift_target)
      expect(new_call_off_contract1.uplift_amount).to eql(call_off_contract1.uplift_amount)
      expect(new_call_off_contract1.set_up_fee).to eql(call_off_contract1.set_up_fee)
      expect(new_call_off_contract1.monthly_service_fee).to eql(call_off_contract1.monthly_service_fee)

      expect(new_call_off_contract1.recruitment_target).to eql(455)
      expect(new_call_off_contract1.revised_target).to eql(455)

      expect(new_call_off_contract1.bands.count).to eql(3)
      band_a, band_b, band_c = new_call_off_contract1.bands

      expect(band_a.min).to eql(0)
      expect(band_a.max).to eql(200)
      expect(band_a.per_participant).to eql(200.0)

      expect(band_b.min).to eql(201)
      expect(band_b.max).to eql(400)
      expect(band_b.per_participant).to eql(150.0)

      expect(band_c.min).to eql(401)
      expect(band_c.max).to eql(455)
      expect(band_c.per_participant).to eql(100.0)
    end
  end
end
