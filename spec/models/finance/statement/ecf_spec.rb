# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement::ECF do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:ecf_lead_provider) { create(:lead_provider, call_off_contract:) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: ecf_lead_provider) }
  subject { create(:ecf_statement, cpd_lead_provider:) }

  describe "#payable!" do
    it "transitions the statement to payable" do
      expect {
        subject.payable!
      }.to change(subject, :type).from("Finance::Statement::ECF").to("Finance::Statement::ECF::Payable")
    end
  end
end
