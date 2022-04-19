# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement::ECF do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:ecf_lead_provider) { create(:lead_provider, call_off_contract: call_off_contract) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: ecf_lead_provider) }
  subject { create(:ecf_statement, cpd_lead_provider: cpd_lead_provider) }

  describe "#cache_original_value!" do
    it "persists value of statement" do
      subject.cache_original_value!
      expect(subject.reload.original_value).to be_within(1).of(22_287.89)
    end
  end

  describe "#payable!" do
    it "transitions the statement to payable" do
      expect {
        subject.payable!
      }.to change(subject, :type).from("Finance::Statement::ECF").to("Finance::Statement::ECF::Payable")
    end
  end
end
