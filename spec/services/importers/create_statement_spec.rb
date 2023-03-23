# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateStatement do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let!(:cohort_2023) { create(:cohort, start_year: 2023) }
  let(:npq_course) { create(:npq_course, identifier: "npq-leading-behaviour-culture") }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    before do
      csv.write "type,name,cohort,deadline_date,payment_date,output_fee"
      csv.write "\n"
      csv.write "ecf,January 2024,2023,2023-12-31,2024-1-25,true"
      csv.write "\n"
      csv.write "ecf,February 2024,2023,2024-1-31,2024-2-25,false"
      csv.write "\n"
      csv.write "npq,January 2024,2023,2023-12-25,2024-1-25,false"
      csv.write "\n"
      csv.write "npq,February 2024,2023,2024-1-25,2024-2-25,true"
      csv.write "\n"
      csv.close
    end

    context "when contracts for the cohort exists" do
      let!(:ecf_contract) { create(:call_off_contract, lead_provider:, version: "0.0.1", cohort: cohort_2023) }
      let!(:npq_contract) { create(:npq_contract, npq_course:, cohort: cohort_2023, npq_lead_provider:) }

      it "creates ECF statements idempotently" do
        expect {
          importer.call
          importer.call
        }.to change(Finance::Statement::ECF, :count).by(2)
      end

      it "creates NPQ statements idempotently" do
        expect {
          importer.call
          importer.call
        }.to change(Finance::Statement::NPQ, :count).by(2)
      end

      it "populates statements correctly" do
        importer.call

        expect(
          Finance::Statement::ECF.find_by(
            name: "January 2024",
            cohort: cohort_2023,
            deadline_date: Date.new(2023, 12, 31),
            payment_date: Date.new(2024, 1, 25),
            contract_version: "0.0.1",
            output_fee: true,
          ),
        ).to be_present

        expect(
          Finance::Statement::ECF.find_by(
            name: "February 2024",
            cohort: cohort_2023,
            deadline_date: Date.new(2024, 1, 31),
            payment_date: Date.new(2024, 2, 25),
            contract_version: "0.0.1",
            output_fee: false,
          ),
        ).to be_present

        expect(
          Finance::Statement::NPQ.find_by(
            name: "January 2024",
            cohort: cohort_2023,
            deadline_date: Date.new(2023, 12, 25),
            payment_date: Date.new(2024, 1, 25),
            contract_version: "0.0.1",
            output_fee: false,
          ),
        ).to be_present

        expect(
          Finance::Statement::NPQ.find_by(
            name: "February 2024",
            cohort: cohort_2023,
            deadline_date: Date.new(2024, 1, 25),
            payment_date: Date.new(2024, 2, 25),
            contract_version: "0.0.1",
            output_fee: true,
          ),
        ).to be_present
      end
    end

    context "when contracts for the cohort does not exist" do
      it "does not create any ECF statement" do
        expect {
          importer.call
        }.not_to change(Finance::Statement::ECF, :count)
      end

      it "does not create any NPQ statement" do
        expect {
          importer.call
        }.not_to change(Finance::Statement::NPQ, :count)
      end
    end
  end
end
