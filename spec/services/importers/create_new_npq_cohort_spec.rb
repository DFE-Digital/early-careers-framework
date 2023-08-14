# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateNewNPQCohort do
  describe "#call" do
    let(:start_year) { Cohort.ordered_by_start_year.last.start_year + 1000 }

    let!(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider, name: "Koala Institute") }
    let!(:npq_leadership_course) { create(:npq_leadership_course, identifier: "npq-headship") }

    let(:cohort_csv) do
      csv = Tempfile.new("cohort_csv_data.csv")
      csv.write "start-year,registration-start-date,academic-year-start-date,npq-registration-start-date"
      csv.write "\n"
      4.times.each do |n|
        csv.write "#{start_year + n},#{start_year + n}/05/10,#{start_year}/09/01,"
        csv.write "\n"
      end
      csv.close
      csv.path
    end

    let(:schedule_csv) do
      csv = Tempfile.new("schedule_csv_data.csv")
      csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
      csv.write "\n"
      csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,#{start_year},Output 1 - Participant Start,started,01/11/#{start_year},01/11/#{start_year},01/11/#{start_year}"
      csv.close
      csv.path
    end

    let(:contract_csv) do
      csv = Tempfile.new("contract_csv_data.csv")
      csv.write "provider_name,cohort_year,course_identifier,recruitment_target,per_participant,service_fee_installments"
      csv.write "\n"
      csv.write "#{cpd_lead_provider.name},#{start_year},npq-headship,321,654.87,14"
      csv.write "\n"
      csv.close
      csv.path
    end

    let(:statement_csv) do
      csv = Tempfile.new("statement_csv_data.csv")
      csv.write "type,name,cohort,deadline_date,payment_date,output_fee"
      csv.write "\n"
      csv.write "npq,January #{start_year + 3},#{start_year},#{start_year}-12-25,#{start_year + 3}-1-25,false"
      csv.write "\n"
      csv.write "npq,February #{start_year + 3},#{start_year},#{start_year + 3}-1-25,#{start_year + 3}-2-25,true"
      csv.write "\n"
      csv.close
      csv.path
    end

    subject do
      described_class.new(cohort_csv:, schedule_csv:, contract_csv:, statement_csv:)
    end

    context "create new cohort" do
      it "creates cohort" do
        current_cohorts_count = Cohort.count
        subject.call
        expect(Cohort.count).to eql(current_cohorts_count + 4)
        expect(Cohort.order(:start_year).last.start_year).to eq(start_year + 3)
      end

      it "creates schedule" do
        current_schedules_count = Finance::Schedule::NPQLeadership.count
        subject.call
        expect(Finance::Schedule::NPQLeadership.count).to eql(current_schedules_count + 1)
        expect(Finance::Schedule::NPQLeadership.where(cohort: Cohort.find_by(start_year:)).first.name).to eql("NPQ Leadership Autumn")
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
        expect(Finance::Statement::NPQ.order(:payment_date).first.name).to eql("January #{start_year + 3}")
      end
    end
  end
end
