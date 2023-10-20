# frozen_string_literal: true

RSpec.describe Oneoffs::ECF::RemoveFeesFromContracts do
  let(:cohort) { create(:cohort, start_year: 2021) }

  subject { described_class.new(cohort_year: 2021, from_date: "2023-10-01") }

  describe "#call" do
    let!(:ecf_statement1) { create(:ecf_statement, cohort:, contract_version: "0.0.1", payment_date: "2023-10-25") }
    let!(:call_off_contract1) do
      create(
        :call_off_contract,
        lead_provider: ecf_statement1.lead_provider,
        cohort: ecf_statement1.cohort,
        version: ecf_statement1.contract_version,
        monthly_service_fee: 1000.0,
      )
    end

    let!(:ecf_statement2) { create(:ecf_statement, cohort:, contract_version: "0.0.4", payment_date: "2023-11-25") }
    let!(:call_off_contract2) do
      create(
        :call_off_contract,
        lead_provider: ecf_statement2.lead_provider,
        cohort: ecf_statement2.cohort,
        version: ecf_statement2.contract_version,
        monthly_service_fee: nil,
      )
    end

    let!(:ecf_statement3) { create(:ecf_statement, cohort:, contract_version: "0.0.7", payment_date: "2023-09-25") }
    let!(:call_off_contract3) do
      create(
        :call_off_contract,
        lead_provider: ecf_statement3.lead_provider,
        cohort: ecf_statement3.cohort,
        version: ecf_statement3.contract_version,
        monthly_service_fee: 9000.0,
      )
    end

    it "should create new contract with zero service fee" do
      expect(Finance::Statement::ECF.count).to eql(3)
      expect(ecf_statement1.reload.contract_version).to eql("0.0.1")
      expect(ecf_statement2.reload.contract_version).to eql("0.0.4")
      expect(ecf_statement3.reload.contract_version).to eql("0.0.7")

      expect(CallOffContract.count).to eql(3)
      expect(CallOffContract.where(monthly_service_fee: 1000.0).count).to eql(1)
      expect(CallOffContract.where(monthly_service_fee: nil).count).to eql(1)
      expect(CallOffContract.where(monthly_service_fee: 9000.0).count).to eql(1)

      subject.call

      expect(Finance::Statement::ECF.count).to eql(3)
      expect(ecf_statement1.reload.contract_version).to eql("0.0.2")
      expect(ecf_statement2.reload.contract_version).to eql("0.0.5")
      expect(ecf_statement3.reload.contract_version).to eql("0.0.7")

      expect(CallOffContract.count).to eql(3 + 2)
      expect(CallOffContract.where(monthly_service_fee: 1000.0).count).to eql(1)
      expect(CallOffContract.where(monthly_service_fee: nil).count).to eql(1)
      expect(CallOffContract.where(monthly_service_fee: 9000.0).count).to eql(1)
      expect(CallOffContract.where(monthly_service_fee: 0.0).count).to eql(2)
    end

    it "should create new contract matching old contract" do
      # Run twice to check for duplicates
      subject.call
      subject.call
      expect(CallOffContract.count).to eql(3 + 2)

      old_call_off_contract1 = CallOffContract.where(
        cohort: call_off_contract1.cohort,
        lead_provider: call_off_contract1.lead_provider,
        version: "0.0.1",
      ).first
      new_call_off_contract1 = CallOffContract.where(
        cohort: call_off_contract1.cohort,
        lead_provider: call_off_contract1.lead_provider,
        version: "0.0.2",
      ).first

      expect(new_call_off_contract1.uplift_target).to eql(old_call_off_contract1.uplift_target)
      expect(new_call_off_contract1.uplift_amount).to eql(old_call_off_contract1.uplift_amount)
      expect(new_call_off_contract1.recruitment_target).to eql(old_call_off_contract1.recruitment_target)
      expect(new_call_off_contract1.set_up_fee).to eql(old_call_off_contract1.set_up_fee)
      expect(new_call_off_contract1.revised_target).to eql(old_call_off_contract1.revised_target)
      expect(new_call_off_contract1.monthly_service_fee).to eql(0.0)
    end

    it "should create new bands matching old contract bands" do
      # Run twice to check for duplicates
      subject.call
      subject.call

      old_call_off_contract1 = CallOffContract.where(
        cohort: call_off_contract1.cohort,
        lead_provider: call_off_contract1.lead_provider,
        version: "0.0.1",
      ).first
      new_call_off_contract1 = CallOffContract.where(
        cohort: call_off_contract1.cohort,
        lead_provider: call_off_contract1.lead_provider,
        version: "0.0.2",
      ).first

      expect(old_call_off_contract1.participant_bands.count).to eql(3)
      expect(new_call_off_contract1.participant_bands.count).to eql(3)

      old_call_off_contract1.participant_bands.each_with_index do |old_band, n|
        new_band = new_call_off_contract1.participant_bands[n]
        expect(new_band.min).to eql(old_band.min)
        expect(new_band.max).to eql(old_band.max)
        expect(new_band.per_participant).to eql(old_band.per_participant)
        expect(new_band.output_payment_percentage).to eql(old_band.output_payment_percentage)
        expect(new_band.service_fee_percentage).to eql(old_band.service_fee_percentage)
      end

      old_call_off_contract2 = CallOffContract.where(
        cohort: call_off_contract2.cohort,
        lead_provider: call_off_contract2.lead_provider,
        version: "0.0.4",
      ).first
      new_call_off_contract2 = CallOffContract.where(
        cohort: call_off_contract2.cohort,
        lead_provider: call_off_contract2.lead_provider,
        version: "0.0.5",
      ).first

      expect(old_call_off_contract2.participant_bands.count).to eql(3)
      expect(new_call_off_contract2.participant_bands.count).to eql(3)

      old_call_off_contract2.participant_bands.each_with_index do |old_band, n|
        new_band = new_call_off_contract2.participant_bands[n]
        expect(new_band.min).to eql(old_band.min)
        expect(new_band.max).to eql(old_band.max)
        expect(new_band.per_participant).to eql(old_band.per_participant)
        expect(new_band.output_payment_percentage).to eql(old_band.output_payment_percentage)
        expect(new_band.service_fee_percentage).to eql(old_band.service_fee_percentage)
      end
    end
  end
end
