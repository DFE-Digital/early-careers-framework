# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateNewNPQCohort do
  describe "#call" do
    let(:cohort_csv) do
      csv = Tempfile.new("cohort_csv_data.csv")
      csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
      csv.write "\n"
      csv.write "2020,2020/05/10,2020/09/01,"
      csv.write "\n"
      csv.write "2021,2021/05/10,2021/09/01,"
      csv.write "\n"
      csv.write "2022,2022/05/10,2022/09/01,"
      csv.write "\n"
      csv.write "2023,2023/05/10,2023/09/01,"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:schedule_csv) do
      csv = Tempfile.new("schedule_csv_data.csv")
      csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
      csv.write "\n"
      csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,2022,Output 1 - Participant Start,started,01/11/2022,01/11/2022,01/11/2022"
      csv.close
      csv.path
    end

    let(:contract_csv) do
      csv = Tempfile.new("contract_csv_data.csv")
      csv.write "provider_name,cohort_year,course_identifier,recruitment_target,per_participant,service_fee_installments"
      csv.write "\n"
      csv.write "Ambition Institute,2022,npq-headship,321,654.87,14"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:statement_csv) do
      csv = Tempfile.new("statement_csv_data.csv")
      csv.write "type,name,cohort,deadline_date,payment_date,output_fee"
      csv.write "\n"
      csv.write "npq,January 2023,2022,2022-12-25,2023-1-25,false"
      csv.write "\n"
      csv.write "npq,February 2023,2022,2023-1-25,2023-2-25,true"
      csv.write "\n"
      csv.close
      csv.path
    end

    let!(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider, name: "Ambition Institute") }
    let!(:npq_leadership_course) { create(:npq_leadership_course, identifier: "npq-headship") }

    subject do
      described_class.new(cohort_csv:, schedule_csv:, contract_csv:, statement_csv:)
    end

    context "create new cohort" do
      it "creates cohort" do
        expect(Cohort.count).to eql(0)
        subject.call
        expect(Cohort.count).to eql(4)
        expect(Cohort.order(:start_year).last.start_year).to eq(2023)
      end

      it "creates schedule" do
        expect(Finance::Schedule::NPQLeadership.count).to eql(0)
        subject.call
        expect(Finance::Schedule::NPQLeadership.count).to eql(1)
        expect(Finance::Schedule::NPQLeadership.first.name).to eql("NPQ Leadership Autumn")
      end

      it "creates npq contract" do
        expect(NPQContract.count).to eql(0)
        subject.call
        expect(NPQContract.count).to eql(1)
        expect(NPQContract.first.course_identifier).to eql("npq-headship")
      end

      it "creates statement" do
        expect(Finance::Statement::NPQ.count).to eql(0)
        subject.call
        expect(Finance::Statement::NPQ.count).to eql(2)
        expect(Finance::Statement::NPQ.order(:payment_date).first.name).to eql("January 2023")
      end
    end
  end
end
