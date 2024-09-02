# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateNewECFCohort do
  describe "#call" do
    # TODO: hard coding year for now here and in csvs due to flaky tests but those need to be dynamic
    let(:start_year) { "2026" }

    let(:cohort_csv) { "spec/fixtures/files/importers/cohort_csv_data.csv" }
    let(:cohort_lead_provider_csv) { "spec/fixtures/files/importers/cohort_lead_provider_csv_data.csv" }
    let(:contract_csv) { "spec/fixtures/files/importers/contract_csv_data.csv" }
    let(:schedule_csv) { "spec/fixtures/files/importers/schedule_csv_data.csv" }
    let(:statement_csv) { "spec/fixtures/files/importers/statement_csv_data.csv" }
    let(:lead_provider) { create(:lead_provider, name: "Ambition Institute", cohorts: []) }
    let!(:cpd_lead_provider) { create(:cpd_lead_provider, name: "Ambition Institute", lead_provider:) }

    subject do
      described_class.new(cohort_csv:, cohort_lead_provider_csv:, contract_csv:, schedule_csv:, statement_csv:)
    end

    context "with missing csvs" do
      let(:statement_csv) {}

      it "raises an error" do
        expect { subject.call }.to raise_error("All scripts need to be present to create a new ECF cohort")
      end
    end

    context "create new ECF cohort" do
      it "creates cohort" do
        expect { subject.call }.to change { Cohort.count }.by(1)
      end

      it "adds lead provider to cohort" do
        expect(lead_provider.cohorts).to be_empty
        subject.call
        expect(lead_provider.reload.cohorts).to contain_exactly(Cohort.find_by(start_year:))
      end

      it "creates Call off Contract and bands" do
        expect(CallOffContract.count).to eql(0)
        expect(ParticipantBand.count).to eql(0)
        subject.call
        expect(CallOffContract.count).to eql(1)
        expect(ParticipantBand.count).to eql(4)
      end

      it "creates schedule" do
        expect { subject.call }.to change { Finance::Schedule::ECF.count }.by(1)
        expect(Finance::Schedule::ECF.order(created_at: :asc).last.name).to eql("ECF Standard September")
      end

      it "creates statement" do
        expect { subject.call }.to change { Finance::Statement::ECF.count }.by(1)
        expect(Finance::Statement::ECF.first.name).to eql("September #{start_year}")
      end
    end
  end
end
