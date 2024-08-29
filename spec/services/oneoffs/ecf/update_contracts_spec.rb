# frozen_string_literal: true

require "tempfile"

RSpec.describe Oneoffs::ECF::UpdateContracts do
  let(:cohort) { create(:cohort, start_year: 2024) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Great Provider") }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let(:csv) { Tempfile.new("contracts.csv") }
  let(:path_to_csv) { csv.path }
  let(:dry_run) { false }

  let(:existing_contract) do
    contract = create(
      :call_off_contract,
      lead_provider:,
      cohort:,
      uplift_target: "0.4",
      uplift_amount: "100",
      recruitment_target: "11500",
      revised_target: "11500",
      set_up_fee: "0",
      monthly_service_fee: "224464",
      version: "0.0.7",
    )
    contract.participant_bands.destroy_all
    create(:participant_band, call_off_contract: contract, min: 0, max: 2000, per_participant: 1355)
    create(:participant_band, call_off_contract: contract, min: 2001, max: 4000, per_participant: 1380)
    create(:participant_band, call_off_contract: contract, min: 4001, max: 11_500, per_participant: 1355)
    contract
  end

  let(:statement) { create(:ecf_statement, cohort:, cpd_lead_provider:, contract_version: "0.0.7") }

  let(:csv_content) do
    <<~CSV
      lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant
      Great Provider,2024,0.4,100,11500,11500,0,224464,0,2000,1355,2001,4000,1380,4001,11500,1355,,,
    CSV
  end

  subject { described_class.new(path_to_csv:) }

  before do
    csv.write(csv_content)
    csv.rewind

    cohort
    lead_provider
  end

  after do
    csv.close
    csv.unlink
  end

  describe "#perform_change" do
    subject { described_class.new(path_to_csv:).perform_change(dry_run:) }

    context "when dry run is true" do
      let(:dry_run) { true }

      it "does not persist any changes" do
        expect { subject }.not_to change { CallOffContract.count }
      end

      it "records information about the dry run" do
        expect(subject).to include("~~~ DRY RUN ~~~")
      end
    end

    context "when dry run is false" do
      context "when there is no existing contract" do
        it "creates a new call off contract if one does not exist" do
          expect { subject }.to change { CallOffContract.count }.by(1)
        end

        it "creates new participant bands" do
          expect { subject }.to change { ParticipantBand.count }.by(3)
        end

        it "updates existing statements with the new contract version" do
          expect(statement.contract_version).to eq("0.0.7")
          subject
          expect(statement.reload.contract_version).to eq("0.0.1")
        end
      end

      context "when the contract already exists and matches data" do
        before do
          existing_contract
        end

        it "does not create a new contract" do
          expect { subject }.not_to change { CallOffContract.count }
        end

        it "records that the existing contract matches" do
          expect(subject).to include("Existing contract matches contract data, no need to update")
        end
      end

      context "when the contract exists but does not match data" do
        let(:csv_content) do
          <<~CSV
            lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant
            Great Provider,2024,0.5,200,11500,11500,0,224464,0,2000,1355,2001,4000,1380,4001,11500,1355,,,
          CSV
        end
        let(:new_contract) { CallOffContract.where.not(id: existing_contract).first }

        before do
          existing_contract
        end

        it "creates contract with correct values" do
          expect { subject }.to change { CallOffContract.count }.by(1)

          expect(new_contract.uplift_target).to eq(0.5)
          expect(new_contract.uplift_amount).to eq(200)
          expect(new_contract.recruitment_target).to eq(11_500)
          expect(new_contract.revised_target).to eq(11_500)
          expect(new_contract.set_up_fee).to eq(0)
          expect(new_contract.monthly_service_fee).to eq(224_464)
          expect(new_contract.bands.count).to eq(3)

          expect(new_contract.bands[0].min).to eq(0)
          expect(new_contract.bands[0].max).to eq(2000)
          expect(new_contract.bands[0].per_participant).to eq(1355)

          expect(new_contract.bands[1].min).to eq(2001)
          expect(new_contract.bands[1].max).to eq(4000)
          expect(new_contract.bands[1].per_participant).to eq(1380)

          expect(new_contract.bands[2].min).to eq(4001)
          expect(new_contract.bands[2].max).to eq(11_500)
          expect(new_contract.bands[2].per_participant).to eq(1355)
        end

        it "creates a new contract version" do
          expect { subject }.to change { CallOffContract.count }.by(1)
          expect(new_contract.version).to eq("0.0.8")
        end

        it "updates the statements with the new version" do
          expect(statement.contract_version).to eq("0.0.7")
          subject
          expect(statement.reload.contract_version).to eq("0.0.8")
        end
      end
    end
  end

  describe "#latest_existing_contract" do
    it "returns the contract with the highest version number" do
      create(:call_off_contract, lead_provider:, cohort:, version: "0.0.2")
      latest_contract = create(:call_off_contract, lead_provider:, cohort:, version: "0.0.5")

      result = subject.latest_existing_contract(lead_provider:, cohort:)

      expect(result).to eq(latest_contract)
    end
  end

  describe "#check_headers!" do
    context "when headers are valid" do
      it "does not raise an error" do
        expect { subject.check_headers! }.not_to raise_error
      end
    end

    context "when headers are invalid" do
      let(:csv_content) do
        <<~CSV
          invalid-header-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant
        CSV
      end

      it "raises a NameError" do
        expect { subject.check_headers! }.to raise_error(NameError, "Invalid CSV headers")
      end
    end
  end

  describe "#existing_contract_matches_contract_data?" do
    let(:contract_data) do
      {
        uplift_target: "0.4",
        uplift_amount: "100",
        recruitment_target: "11500",
        revised_target: "11500",
        set_up_fee: "0",
        monthly_service_fee: "224464",
        band_a: { min: "0", max: "2000", per_participant: "1355" },
        band_b: { min: "2001", max: "4000", per_participant: "1380" },
        band_c: { min: "4001", max: "11500", per_participant: "1355" },
        band_d: { min: nil, max: nil, per_participant: nil },
      }
    end

    context "when all contract fields match exactly" do
      it "returns true" do
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be true
      end
    end

    context "when a contract field is different" do
      it "returns false when uplift_target differs" do
        contract_data[:uplift_target] = "0.5"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when uplift_amount differs" do
        contract_data[:uplift_amount] = "200"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when recruitment_target differs" do
        contract_data[:recruitment_target] = "12000"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when revised_target differs" do
        contract_data[:revised_target] = "12000"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when set_up_fee differs" do
        contract_data[:set_up_fee] = "100"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when monthly_service_fee differs" do
        contract_data[:monthly_service_fee] = "300000"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end
    end

    context "when a band field is different" do
      it "returns false when band_a min differs" do
        contract_data[:band_a][:min] = "100"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when band_b max differs" do
        contract_data[:band_b][:max] = "4500"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when band_c per_participant differs" do
        contract_data[:band_c][:per_participant] = "1400"
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end

      it "returns false when a new band_d is introduced" do
        contract_data[:band_d] = { min: "11501", max: "12000", per_participant: "1500" }
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end
    end

    context "when existing contract has band d" do
      before do
        create(:participant_band, call_off_contract: existing_contract, min: 11_501, max: 12_000, per_participant: 1500)
      end

      it "returns false" do
        expect(subject.existing_contract_matches_contract_data?(existing_contract:, contract_data:)).to be false
      end
    end

    context "when the existing contract is nil" do
      it "returns false if no existing contract is found" do
        expect(subject.existing_contract_matches_contract_data?(existing_contract: nil, contract_data:)).to be false
      end
    end
  end
end
