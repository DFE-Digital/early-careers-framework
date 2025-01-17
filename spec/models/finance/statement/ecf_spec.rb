# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement::ECF do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let(:contract_version) { "0.0.2" }

  let!(:call_off_contract) { create(:call_off_contract, cohort:, lead_provider:, version: contract_version) }
  let!(:mentor_call_off_contract) { create(:mentor_call_off_contract, cohort:, lead_provider:, version: contract_version) }

  subject { create(:ecf_statement, cpd_lead_provider:, cohort:, contract_version:) }

  describe "#payable!" do
    it "transitions the statement to payable" do
      expect {
        subject.payable!
      }.to change(subject, :type).from("Finance::Statement::ECF").to("Finance::Statement::ECF::Payable")
    end
  end

  describe "#contract" do
    it "returns call_off_contract" do
      expect(subject.contract).to eq(call_off_contract)
    end
  end

  describe "#mentor_contract" do
    it "returns mentor_call_off_contract" do
      expect(subject.mentor_contract).to eq(mentor_call_off_contract)
    end
  end
end
