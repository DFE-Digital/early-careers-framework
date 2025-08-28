# frozen_string_literal: true

RSpec.describe Oneoffs::UpdateMentorContracts do
  let!(:cohort) { create(:cohort, start_year: 2025) }
  let!(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Great Provider") }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:statement) { create(:ecf_statement, cohort:, cpd_lead_provider:, contract_version: "0.0.7") }

  let(:dry_run) { false }

  let(:csv_content) do
    <<~CSV
      lead-provider-name,cohort-start-year,recruitment-target,payment-per-participant
      Great Provider,2025,100,11500
    CSV
  end

  let(:instance) { described_class.new(path_to_csv:) }
  subject(:perform_change) { instance.perform_change(dry_run:) }

  let(:csv) { Tempfile.new("mentor_contracts.csv") }
  let(:path_to_csv) { csv.path }

  before do
    allow(Rails.logger).to receive(:info)

    csv.write(csv_content)
    csv.rewind
  end

  after do
    csv.close
    csv.unlink
  end

  describe "#perform_change" do
    context "when dry run is false" do
      it { is_expected.to eq(instance.recorded_info) }

      context "when there are no existing mentor contracts" do
        it "creates a new mentor call off contract with correct values " do
          expect { perform_change }.to change { MentorCallOffContract.count }.by(1)

          new_mentor_contract = MentorCallOffContract.first
          expect(new_mentor_contract.recruitment_target).to eq(100)
          expect(new_mentor_contract.payment_per_participant).to eq(11_500)
        end

        it "updates existing statements with the new mentor contract version" do
          expect { perform_change }.to change { statement.reload.mentor_contract_version }.to("0.0.1")
        end
      end

      context "when a mentor contract already exists and matches data" do
        let!(:existing_mentor_contract) do
          create(
            :mentor_call_off_contract,
            lead_provider:,
            cohort:,
            recruitment_target: 100,
            payment_per_participant: 11_500,
            version: "0.0.7",
          )
        end

        it "does not create a new mentor contract" do
          expect { perform_change }.not_to change { MentorCallOffContract.count }
        end

        it "records that the existing contract matches" do
          expect(perform_change).to include("Existing contract matches contract data, no need to update")
        end
      end

      context "when the contract exists but does not match data" do
        let!(:older_mentor_contract) do
          create(
            :mentor_call_off_contract,
            lead_provider:,
            cohort:,
            recruitment_target: 10,
            payment_per_participant: 500,
            version: "0.0.6",
          )
        end

        let!(:existing_mentor_contract) do
          create(
            :mentor_call_off_contract,
            lead_provider:,
            cohort:,
            recruitment_target: 50,
            payment_per_participant: 1000,
            version: "0.0.7",
          )
        end
        let(:new_mentor_contract) { MentorCallOffContract.where.not(id: [existing_mentor_contract, older_mentor_contract]).first }

        it "creates mentor contract with correct values" do
          expect { perform_change }.to change { MentorCallOffContract.count }.by(1)

          expect(new_mentor_contract.recruitment_target).to eq(100)
          expect(new_mentor_contract.payment_per_participant).to eq(11_500)
        end

        it "creates a new mentor contract version" do
          perform_change

          expect(new_mentor_contract.version).to eq("0.0.8")
        end

        it "updates the statements with the new version" do
          expect { perform_change }.to change { statement.reload.mentor_contract_version }.to("0.0.8")
        end
      end

      context "when headers are invalid" do
        let(:csv_content) do
          <<~CSV
            invalid-header-name,cohort-start-year,recruitment-target,payment-per-participant
          CSV
        end

        it "raises a NameError" do
          expect { perform_change }.to raise_error(NameError, "Invalid CSV headers")
        end
      end

      context "when dry run is true" do
        let(:dry_run) { true }

        it "does not persist any changes" do
          expect { perform_change }.not_to change { MentorCallOffContract.count }
        end

        it "records information about the dry run" do
          expect(perform_change).to include("~~~ DRY RUN ~~~")
        end
      end
    end
  end
end
