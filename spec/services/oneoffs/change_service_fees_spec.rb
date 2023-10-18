# frozen_string_literal: true

describe Oneoffs::ChangeServiceFees do
  let(:cpd_lead_provider) { ecf_statement.cpd_lead_provider }
  let(:cohort) { create(:cohort, start_year: 2021) }

  let!(:ecf_statement) { create(:ecf_statement, cohort:, contract_version: "0.0.2", payment_date: Date.new(2023, 10, 25)) }
  let!(:call_off_contract) { create(:call_off_contract, lead_provider: ecf_statement.lead_provider, cohort:, version: ecf_statement.contract_version, monthly_service_fee: 10) }

  let(:instance) { described_class.new(cpd_lead_provider:, cohort:) }

  before { allow(Rails.logger).to receive(:info) }

  describe "#perform_change" do
    let(:date_range) { Date.new(2023, 10, 1)..Date.new(2023, 10, 31) }
    let(:monthly_service_fee) { 20 }
    let(:dry_run) { false }

    subject(:perform_change) { instance.perform_change(date_range:, monthly_service_fee:, dry_run:) }

    it "duplicates the latest contract with a new version/monthly_service_fee" do
      expect { perform_change }.to change { CallOffContract.count }.by(1)

      expected_attributes = call_off_contract
        .attributes
        .symbolize_keys
        .except(:id, :created_at, :updated_at)
        .merge!(
          version: "0.0.3",
          monthly_service_fee: 20,
        )

      created_contract = CallOffContract.order(:created_at).last
      expect(created_contract).to have_attributes(expected_attributes)
    end

    it "duplicates the participant bands for the new contract" do
      participant_bands_count = call_off_contract.participant_bands.count

      expect { perform_change }.to change { ParticipantBand.count }.by(participant_bands_count)

      created_contract = CallOffContract.order(:created_at).last
      created_participant_bands = ParticipantBand.order(:created_at).last(participant_bands_count)

      created_participant_bands.each_with_index do |band, index|
        expected_attributes = call_off_contract.participant_bands[index]
          .attributes
          .symbolize_keys
          .except(:id, :created_at, :updated_at)
          .merge!(call_off_contract_id: created_contract.id)

        expect(band).to have_attributes(expected_attributes)
      end
    end

    it "logs out information" do
      perform_change

      expect_changes([
        "Current contract version: 0.0.2, fee: 10.0",
        "New contract version: 0.0.3, fee: 20.0",
        "Updating statement dated: 2023-10-25",
      ])
    end

    it "updates the contract_version for statements in the given date range" do
      expect { perform_change }.to change { ecf_statement.reload.contract_version }.from("0.0.2").to("0.0.3")
    end

    it "does not change statements outside the given date range" do
      ecf_statement_out_of_date_range = create(:ecf_statement, cohort:, payment_date: date_range.last + 1.day)

      expect { perform_change }.not_to change { ecf_statement_out_of_date_range.reload.contract_version }
    end

    it "does not change statements with other cohorts" do
      other_cohort = create(:cohort, start_year: 2023)
      ecf_statement_other_cohort = create(:ecf_statement, cohort: other_cohort, payment_date: Date.new(2023, 10, 25), cpd_lead_provider: ecf_statement.cpd_lead_provider)

      expect { perform_change }.not_to change { ecf_statement_other_cohort.reload.contract_version }
    end

    it "does not change statements with other lead providers" do
      other_cpd_lead_provider = create(:cpd_lead_provider)
      ecf_statement_other_lead_provider = create(:ecf_statement, cohort:, payment_date: Date.new(2023, 10, 25), cpd_lead_provider: other_cpd_lead_provider)

      expect { perform_change }.not_to change { ecf_statement_other_lead_provider.reload.contract_version }
    end

    it "selects the latest contract to duplicate by version" do
      create(:call_off_contract, lead_provider: ecf_statement.lead_provider, cohort:, version: "0.0.1")

      perform_change

      created_contract = CallOffContract.order(:created_at).last
      expect(created_contract.version).to eq("0.0.3")
    end

    it "ignores contracts with other cohorts" do
      other_cohort = create(:cohort, start_year: 2023)
      create(:call_off_contract, lead_provider: ecf_statement.lead_provider, cohort: other_cohort, version: "0.0.4")

      perform_change

      created_contract = CallOffContract.order(:created_at).last
      expect(created_contract.version).to eq("0.0.3")
    end

    it "ignores contracts with other lead providers" do
      other_lead_provider = create(:lead_provider)
      create(:call_off_contract, lead_provider: other_lead_provider, cohort:, version: "0.0.4")

      perform_change

      created_contract = CallOffContract.order(:created_at).last
      expect(created_contract.version).to eq("0.0.3")
    end

    context "when a matching contract is not found" do
      let!(:call_off_contract) { nil }

      it { expect { perform_change }.to raise_error(described_class::CallOffContractNotFoundError) }
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not make any changes, but records the changes it would make" do
        expect { perform_change }.not_to change { CallOffContract.count }
        expect_changes([
          "~~~ DRY RUN ~~~",
          "Current contract version: 0.0.2, fee: 10.0",
          "New contract version: 0.0.3, fee: 20.0",
          "Updating statement dated: 2023-10-25",
        ])
      end
    end
  end

  def expect_changes(changes)
    Array.wrap(changes).each do |change|
      expect(instance.changes).to include(change)
      expect(Rails.logger).to have_received(:info).with(change)
    end
  end
end
