# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateNewECFCohort do
  describe "#call" do
    let(:cohort_csv) do
      csv = Tempfile.new("cohort_csv_data.csv")
      csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
      csv.write "\n"
      csv.write "2023,2023/05/10,2023/09/01"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:cohort_lead_provider_csv) do
      csv = Tempfile.new("cohort_lead_provider_csv_data.csv")
      csv.write "lead-provider-name,cohort-start-year"
      csv.write "\n"
      csv.write "Ambition Institute,2023"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:contract_csv) do
      csv = Tempfile.new("contract_csv_data.csv")
      csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
      csv.write "\n"
      csv.write "Ambition Institute,2023,0.44,200,4600,4790,0,0,90,895,91,199,700,200,299,600,300,400,500"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:schedule_csv) do
      csv = Tempfile.new("schedule_csv_data.csv")
      csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
      csv.write "\n"
      csv.write "ecf_standard,ecf-standard-september,ECF Standard September,2023,Output 1 - Participant Start,started,2023/09/01,2023/11/30,2023/11/30"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:statement_csv) do
      csv = Tempfile.new("statement_csv_data.csv")
      csv.write "type,name,cohort,deadline_date,payment_date,output_fee"
      csv.write "\n"
      csv.write "ecf,September 2023,2023,2023-09-01,2023-11-25,true"
      csv.write "\n"
      csv.close
      csv.path
    end

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
        expect(Cohort.count).to eql(0)
        subject.call
        expect(Cohort.count).to eql(1)
        expect(Cohort.first.start_year).to eq(2023)
      end

      it "adds lead provider to cohort" do
        expect(lead_provider.cohorts).to be_empty
        subject.call
        expect(lead_provider.reload.cohorts).to contain_exactly(Cohort.find_by(start_year: 2023))
      end

      it "creates Call off Contract and bands" do
        expect(CallOffContract.count).to eql(0)
        expect(ParticipantBand.count).to eql(0)
        subject.call
        expect(CallOffContract.count).to eql(1)
        expect(ParticipantBand.count).to eql(4)
      end

      it "creates schedule" do
        expect(Finance::Schedule::ECF.count).to eql(0)
        subject.call
        expect(Finance::Schedule::ECF.count).to eql(1)
        expect(Finance::Schedule::ECF.first.name).to eql("ECF Standard September")
      end

      it "creates statement" do
        expect(Finance::Statement::ECF.count).to eql(0)
        subject.call
        expect(Finance::Statement::ECF.count).to eql(1)
        expect(Finance::Statement::ECF.first.name).to eql("September 2023")
      end
    end
  end
end
