# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CallOffContracts do
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
      let(:lead_provider) { create(:lead_provider) }
      let(:contract) { build(:call_off_contract, lead_provider: lead_provider) }

      before do
        csv.write Exporters::CallOffContracts.new.send(:headers).join(",")
        csv.write "\n"
        csv.write [contract.version,
                   contract.uplift_target,
                   contract.uplift_amount,
                   contract.recruitment_target,
                   contract.set_up_fee,
                   contract.revised_target,
                   contract.lead_provider.name].join(",")
        csv.close
      end

      it "creates the new contract" do
        expect {
          subject.call
        }.to change(CallOffContract, :count).by(1)

        persisted_contract = CallOffContract.last

        expect(persisted_contract.uplift_target).to eql(contract.uplift_target)
        expect(persisted_contract.uplift_amount).to eql(contract.uplift_amount)
        expect(persisted_contract.recruitment_target).to eql(contract.recruitment_target)
        expect(persisted_contract.set_up_fee).to eql(contract.set_up_fee)
        expect(persisted_contract.revised_target).to eql(contract.revised_target)
      end
    end

    context "when the contract already exists" do
      let(:contract) { create(:call_off_contract, revised_target: 0) }

      before do
        csv.write Exporters::CallOffContracts.new.send(:headers).join(",")
        csv.write "\n"
        csv.write [contract.version,
                   contract.uplift_target + 1,
                   contract.uplift_amount + 2,
                   contract.recruitment_target + 3,
                   contract.set_up_fee + 4,
                   contract.revised_target + 5,
                   contract.lead_provider.name].join(",")
        csv.close
      end

      it "does not create a new contract" do
        expect {
          subject.call
        }.not_to change(CallOffContract, :count)
      end

      it "updates the existing contract" do
        expect {
          subject.call
          contract.reload
        }.to change { contract.uplift_target }.by(1)
          .and change { contract.uplift_amount }.by(2)
          .and change { contract.recruitment_target }.by(3)
          .and change { contract.set_up_fee }.by(4)
          .and change { contract.revised_target }.by(5)
      end
    end
  end
end
