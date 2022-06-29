# frozen_string_literal: true

RSpec.describe Importers::SeedStatements do
  let!(:cpd_lead_provider) do
    create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider)
  end

  before { create(:cohort, :current) }

  describe "#call" do
    it "creates ECF statements idempotently" do
      expect {
        subject.call
        subject.call
      }.to change(Finance::Statement::ECF, :count).by(30)
    end

    it "creates NPQ statements idempotently" do
      expect {
        subject.call
        subject.call
      }.to change(Finance::Statement::NPQ, :count).by(36)
    end

    context "with updated contract version" do
      let(:new_contract_version) { "99.99.99" }
      let(:statement_name) { "May 2024" }

      before do
        subject.call
        allow(subject).to receive(method_name).and_return(altered_statements)
        subject.call
      end

      context "when ECF statements" do
        let(:method_name) { :ecf_statements }
        let(:altered_statements) do
          [OpenStruct.new(name: statement_name, deadline_date: Date.new(2024, 4, 30), payment_date: Date.new(2024, 5, 25), contract_version: new_contract_version, output_fee: true)]
        end

        it "does not creates duplicate statements" do
          expect(Finance::Statement::ECF.where(name: statement_name).count).to eq(1)
        end
      end

      context "when NPQ statements" do
        let(:method_name) { :npq_statements }
        let(:altered_statements) do
          [OpenStruct.new(name: statement_name, deadline_date: Date.new(2024, 4, 25), payment_date: Date.new(2024, 5, 25), contract_version: new_contract_version, output_fee: false)]
        end

        it "does not creates duplicate statements" do
          expect(Finance::Statement::NPQ.where(name: statement_name).count).to eq(1)
        end
      end
    end
  end
end
