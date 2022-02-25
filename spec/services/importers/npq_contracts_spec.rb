# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::NPQContracts do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject do
    described_class.new(path_to_csv: path_to_csv)
  end

  describe "#call" do
    context "incorrect csv" do
      before do
        csv.write "csv,with,wrong,headers"
        csv.close
      end

      it "raises an error" do
        expect {
          subject.call
        }.to raise_error(NameError, "Invalid headers")
      end
    end

    context "when the contract does not exist" do
      let(:npq_lead_provider) { create(:npq_lead_provider) }
      let(:contract) { build(:npq_contract, npq_lead_provider: npq_lead_provider) }

      before do
        csv.write Exporters::NPQContracts.new.send(:headers).join(",")
        csv.write "\n"
        csv.write [contract.version,
                   contract.npq_lead_provider.name,
                   contract.recruitment_target,
                   contract.course_identifier,
                   contract.service_fee_installments,
                   contract.service_fee_percentage,
                   contract.per_participant,
                   contract.number_of_payment_periods,
                   contract.output_payment_percentage].join(",")
        csv.close
      end

      it "creates the new contract" do
        expect {
          subject.call
        }.to change(NPQContract, :count).by(1)

        persisted_contract = NPQContract.last

        expect(persisted_contract.version).to eql(contract.version)
        expect(persisted_contract.npq_lead_provider).to eql(npq_lead_provider)
        expect(persisted_contract.recruitment_target).to eql(contract.recruitment_target)
        expect(persisted_contract.course_identifier).to eql(contract.course_identifier)
        expect(persisted_contract.service_fee_installments).to eql(contract.service_fee_installments)
        expect(persisted_contract.service_fee_percentage).to eql(contract.service_fee_percentage)
        expect(persisted_contract.per_participant).to eql(contract.per_participant)
        expect(persisted_contract.number_of_payment_periods).to eql(contract.number_of_payment_periods)
        expect(persisted_contract.output_payment_percentage).to eql(contract.output_payment_percentage)
      end
    end

    context "when the contract already exists" do
      let(:contract) { create(:npq_contract) }

      before do
        csv.write Exporters::NPQContracts.new.send(:headers).join(",")
        csv.write "\n"
        csv.write [contract.version,
                   contract.npq_lead_provider.name,
                   contract.recruitment_target + 1,
                   contract.course_identifier,
                   contract.service_fee_installments + 2,
                   contract.service_fee_percentage + 3,
                   contract.per_participant + 4,
                   contract.number_of_payment_periods + 5,
                   contract.output_payment_percentage + 6].join(",")
        csv.close
      end

      it "does not create a new contract" do
        expect {
          subject.call
        }.not_to change(NPQContract, :count)
      end

      it "updates the existing contract" do
        expect {
          subject.call
          contract.reload
        }.to change { contract.recruitment_target }.by(1)
          .and change { contract.service_fee_installments }.by(2)
          .and change { contract.service_fee_percentage }.by(3)
          .and change { contract.per_participant }.by(4)
          .and change { contract.number_of_payment_periods }.by(5)
          .and change { contract.output_payment_percentage }.by(6)
      end
    end
  end
end
