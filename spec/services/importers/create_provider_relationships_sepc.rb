# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateProviderRelationships do
  let(:path_to_csv) { csv.path }
  let(:cohort_start_year) { 2021 }

  let(:csv) { Tempfile.new("data.csv") }
  let(:headers) { "delivery_partner_id,lead_provider_name" }
  let(:invalid_headers) { "delivery_partner_id,some_other_column" }

  subject(:importer) { described_class.new(path_to_csv:, cohort_start_year:) }

  describe "#call" do
    context "when csv headers invalid" do
      before do
        csv.write invalid_headers
        csv.write "\n"
        csv.write "feea2811-6157-439e-9259-46ceb4648844,Ambition Institute"
        csv.write "\n"
        csv.close
      end

      it "raises an error" do
        expect { importer.call }.to raise_error(NameError)
      end
    end

    context "when cohort does not exist" do
      let!(:lead_provider) { create(:lead_provider, name: "Ambition Institute", cohorts: []) }
      before do
        csv.write headers
        csv.write "\n"
        csv.write "feea2811-6157-439e-9259-46ceb4648844,Ambition Institute"
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
        csv.write headers
        csv.write "\n"
        csv.write "48b7abcc-f28f-4e7d-b98c-94f42081b67f,Ambition Institute"
        csv.write "\n"
        csv.close
      end

      it "raises an error" do
        expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when csv valid" do
      let!(:cohort_2021) { create(:cohort, start_year: 2021) }
      let!(:cohort_2022) { create(:cohort, start_year: 2022) }
      let!(:delivery_partner_1) { create(:delivery_partner) }
      let!(:delivery_partner_2) { create(:delivery_partner) }
      let!(:lead_provider_1) { create(:lead_provider, name: "Ambition Institute", cohorts: [cohort_2021, cohort_2022]) }
      let!(:lead_provider_2) { create(:lead_provider, name: "Best Practice Network", cohorts: [cohort_2021]) }

      before do
        csv.write headers
        csv.write "\n"
        csv.write "#{delivery_partner_1.id},#{lead_provider_1.name}"
        csv.write "\n"
        csv.write "#{delivery_partner_1.id},#{lead_provider_2.name}"
        csv.write "\n"
        csv.write "#{delivery_partner_2.id},#{lead_provider_1.name}"
        csv.write "\n"
        csv.close
      end

      it "creates the provider relationships" do
        importer.call

        expect(lead_provider_1.reload.delivery_partners).to include(delivery_partner_1, delivery_partner_2)
        expect(lead_provider_2.reload.delivery_partners).to include(delivery_partner_1)
      end

      it "doesn't create douplicate provider relationships" do
        importer.call

        expect { importer.call }.not_to change(ProviderRelationship, :count)
      end
    end
  end
end
