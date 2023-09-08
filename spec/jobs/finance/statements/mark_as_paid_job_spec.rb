# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::MarkAsPaidJob do
  subject { described_class.new.perform(statement_id:) }

  let!(:statement) { create(:ecf_payable_statement) }

  context "with correct params" do
    let(:service_class) { double(Statements::MarkAsPaid) }
    let(:statement_id) { statement.id }

    context "when statement is payable" do
      it "calls the correct service class" do
        expect(Statements::MarkAsPaid).to receive(:new).with(statement).and_return(service_class)
        expect(service_class).to receive(:call)

        subject
      end
    end

    context "when statement is not payable" do
      let!(:statement) { create(:ecf_statement) }

      it "doest not call the service class" do
        expect(Statements::MarkAsPaid).not_to receive(:new).with(statement)

        subject
      end
    end
  end

  context "with incorrect params" do
    before { allow(Rails.logger).to receive(:warn) }

    let(:statement_id) { SecureRandom.uuid }

    it "doest not call the service class" do
      expect(Statements::MarkAsPaid).not_to receive(:new).with(statement)

      subject
    end

    it "logs a warning" do
      subject

      expect(Rails.logger).to have_received(:warn).with("Statement could not be found - statement_id: #{statement_id}")
    end
  end

  context "with no params" do
    let(:statement_id) { nil }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end
end
