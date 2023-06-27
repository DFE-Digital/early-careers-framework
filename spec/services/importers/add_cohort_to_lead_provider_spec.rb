# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::AddCohortToLeadProvider do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    context "when csv headers invalid" do
      before do
        csv.write "some-other-column,cohort-start-year"
        csv.write "\n"
        csv.write "Beaver Institute,2021"
        csv.write "\n"
        csv.close
      end

      it "raises an error" do
        expect { importer.call }.to raise_error(NameError)
      end
    end

    context "when cohort does not exist" do
      let(:start_year) { Cohort.ordered_by_start_year.last.start_year + 99 }
      let!(:lead_provider) { create(:lead_provider, name: "Ambition Institute", cohorts: []) }
      before do
        csv.write "lead-provider-name,cohort-start-year"
        csv.write "\n"
        csv.write "#{lead_provider.name},#{start_year}"
        csv.write "\n"
        csv.close
      end

      it "raises an error" do
        expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when lead provider does not exist" do
      let!(:cohort_2021) { create(:cohort, start_year: 2021) }
      before do
        csv.write "lead-provider-name,cohort-start-year"
        csv.write "\n"
        csv.write "Cuckoo Institute,2021"
        csv.write "\n"
        csv.close
      end

      it "raises an error" do
        expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when csv valid" do
      let!(:lead_provider_1) { create(:lead_provider, name: "Lizard Institute", cohorts: []) }
      let!(:lead_provider_2) { create(:lead_provider, name: "Best Zoo Network", cohorts: []) }
      let!(:cohort_2021) { create(:cohort, start_year: 2021) }
      let!(:cohort_2022) { create(:cohort, start_year: 2022) }
      let!(:cohort_2023) { create(:cohort, start_year: 2023) }

      before do
        csv.write "lead-provider-name,cohort-start-year"
        csv.write "\n"
        csv.write "#{lead_provider_1.name},2021"
        csv.write "\n"
        csv.write "#{lead_provider_1.name},2022"
        csv.write "\n"
        csv.write "#{lead_provider_1.name},2023"
        csv.write "\n"
        csv.write "#{lead_provider_2.name},2023"
        csv.write "\n"
        csv.close
      end

      it "adds cohorts to lead providers" do
        importer.call

        expect(lead_provider_1.reload.cohorts).to contain_exactly(cohort_2021, cohort_2022, cohort_2023)
        expect(lead_provider_2.reload.cohorts).to contain_exactly(cohort_2023)
      end
    end

    context "when lead provider already belongs to cohorts" do
      let!(:cohort_2021) { create(:cohort, start_year: 2021) }
      let!(:cohort_2022) { create(:cohort, start_year: 2022) }
      let!(:cohort_2023) { create(:cohort, start_year: 2023) }
      let!(:lead_provider_1) { create(:lead_provider, name: "Lion Institute", cohorts: [cohort_2021, cohort_2023]) }

      before do
        csv.write "lead-provider-name,cohort-start-year"
        csv.write "\n"
        csv.write "#{lead_provider_1.name},2022"
        csv.write "\n"
        csv.close
      end

      it "adds new cohorts while maintaining old cohorts" do
        importer.call

        expect(lead_provider_1.reload.cohorts).to contain_exactly(cohort_2021, cohort_2022, cohort_2023)
      end
    end
  end
end
