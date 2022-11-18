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

  describe "#show_targeted_delivery_funding?" do
    context "cohort 2021" do
      subject { build(:npq_statement, cohort: build(:cohort, start_year: 2021)) }

      it "returns false" do
        expect(subject.show_targeted_delivery_funding?).to eql(false)
      end
    end

    context "cohort 2022" do
      subject { build(:npq_statement, cohort: build(:cohort, start_year: 2022)) }

      it "returns true" do
        expect(subject.show_targeted_delivery_funding?).to eql(true)
      end
    end
  end
end
