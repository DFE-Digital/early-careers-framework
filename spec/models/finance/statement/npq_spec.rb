# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statement::NPQ do
  subject { create(:npq_statement) }

  describe "#payable!" do
    it "transitions the statement to payable" do
      expect {
        subject.payable!
      }.to change(subject, :type).from("Finance::Statement::NPQ").to("Finance::Statement::NPQ::Payable")
    end
  end
end
