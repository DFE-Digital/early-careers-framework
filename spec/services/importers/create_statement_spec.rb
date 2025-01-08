# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateStatement do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:cohort_2023) { create(:cohort, start_year: 2023) }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    before do
      csv.write "type,name,cohort,deadline_date,payment_date,output_fee"
      csv.write "\n"
      csv.write "ecf,January 2024,2023,2023-12-31,2024-1-25,true"
      csv.write "\n"
      csv.write "ecf,February 2024,2023,2024-1-31,2024-2-25,false"
      csv.write "\n"
      csv.close
    end

    context "when contracts for the cohort exists" do
      let!(:ecf_contract) { create(:call_off_contract, lead_provider:, version: "0.0.1", cohort: cohort_2023) }

      it "creates ECF statements idempotently" do
        expect {
          importer.call
          importer.call
        }.to change(Finance::Statement::ECF, :count).by(2)
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
      end
    end

    context "when existing statements have newer version" do
      let!(:ecf_contract) { create(:call_off_contract, lead_provider:, version: "0.0.1", cohort: cohort_2023) }

      before do
        statement_attributes = {
          name: "December 2023",
          deadline_date: "2023-11-30",
          payment_date: "2023-12-25",
          output_fee: false,
          cpd_lead_provider:,
          cohort: cohort_2023,
        }

        [Finance::Statement::ECF].each do |statement_type|
          # Later version with different lead provider
          statement_type.create!(
            statement_attributes.merge({
              cpd_lead_provider: create(:cpd_lead_provider, :with_lead_provider),
              contract_version: "0.0.8",
            }),
          )

          # Later version with different cohort
          statement_type.create!(
            statement_attributes.merge({
              cohort: cohort_2023.previous,
              contract_version: "0.0.8",
            }),
          )

          # Later version with earlier payment_date
          statement_type.create!(
            statement_attributes.merge({
              contract_version: "0.0.8",
              payment_date: "2023-12-24",
            }),
          )
        end

        # Latest, relevant ECF statement
        Finance::Statement::ECF.create!(
          statement_attributes.merge({
            contract_version: "0.0.5",
          }),
        )
      end

      it "creates ECF statement with latest version" do
        importer.call

        st = Finance::Statement::ECF.find_by(
          name: "January 2024",
          cohort: cohort_2023,
          deadline_date: Date.new(2023, 12, 31),
          payment_date: Date.new(2024, 1, 25),
        )

        expect(st.contract_version).to eql("0.0.5")
      end
    end

    context "when contracts for the cohort does not exist" do
      it "does not create any ECF statement" do
        expect {
          importer.call
        }.not_to change(Finance::Statement::ECF, :count)
      end
    end
  end
end
