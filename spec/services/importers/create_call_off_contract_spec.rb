# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateCallOffContract do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    context "when no csv given" do
      let(:path_to_csv) {}
      let!(:lead_provider_1) { create(:lead_provider, name: "Penguin Institute") }
      let!(:lead_provider_2) { create(:lead_provider, name: "Apples") }

      it "creates seed call off contracts for all lead providers in three cohorts" do
        # Cohorts from 2021 to today, multiplied by 2x providers
        contracts_count = (Time.zone.today.year - 2021 + 1) * 2
        expect { importer.call }.to change(CallOffContract, :count).by(contracts_count)
      end

      it "creates four bands for each contract" do
        # Cohorts from 2021 to today, multiplied by 2x provider and 4x bands
        bands_count = (Time.zone.today.year - 2021 + 1) * 2 * 4
        expect { importer.call }.to change(ParticipantBand, :count).by(bands_count)
      end

      context "when in production env" do
        before do
          allow(Rails).to receive(:env).and_return ActiveSupport::EnvironmentInquirer.new("production")
        end

        it "raises an error and does not create records" do
          expect { importer.call }.to raise_error(RuntimeError, /do not seed default call off contracts in production/i)
          expect(CallOffContract.count).to be_zero
          expect(ParticipantBand.count).to be_zero
        end
      end

      context "when cohort does not include uplift fees" do
        let(:cohort) { create(:cohort, start_year: 2025) }

        it "sets nil to `uplift_amount`" do
          importer.call

          expect(CallOffContract.where(cohort:).pluck(:uplift_amount)).to match_array([nil, nil])
        end
      end
    end

    context "when csv given" do
      context "when csv headers invalid" do
        before do
          csv.write "some-other-column,cohort-start-year"
          csv.write "\n"
          csv.write "Arctic Wolf Institute,2021"
          csv.write "\n"
          csv.close
        end

        it "raises an error" do
          expect { importer.call }.to raise_error(NameError)
        end
      end

      context "when lead provider does not exist" do
        let!(:cohort_2021) { create(:cohort, start_year: 2021) }
        before do
          csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
          csv.write "\n"
          csv.write "Aardvark Institute,2021,0.44,200,4600,4790,0,2300,0,90,895,91,199,700,200,299,600,300,400,500"
          csv.write "\n"
          csv.close
        end

        it "raises an error" do
          expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when cohort does not exist" do
        let(:year_without_cohort) { Cohort.ordered_by_start_year.last.start_year + 2000 }
        let!(:lead_provider) { create(:lead_provider, name: "Koala Institute") }
        before do
          csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{year_without_cohort},0.44,200,4600,4790,0,2300,0,90,895,91,199,700,200,299,600,300,400,500"
          csv.write "\n"
          csv.close
        end

        it "raises an error" do
          expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when lead provider does not belong in supplied cohort" do
        let!(:lead_provider) { create(:lead_provider, name: "Kangaroo Institute", cohorts: []) }
        let!(:cohort) { create(:cohort) }
        before do
          csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{cohort.start_year},0.44,200,4600,4790,0,2300,0,90,895,91,199,700,200,299,600,300,400,500"
          csv.write "\n"
          csv.close
        end

        it "raises an error" do
          expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the lead provider has an existing call off contract in the cohort" do
        let!(:cohort) { create(:seed_cohort) }
        let!(:lead_provider) { create(:lead_provider, name: "Whale Institute", cohorts: [cohort]) }
        let!(:call_off_contract) { create(:call_off_contract, cohort:, lead_provider:) }
        before do
          csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{cohort.start_year},0.44,200,4600,4790,0,2300,0,90,895,91,199,700,200,299,600,300,400,500"
          csv.write "\n"
          csv.close
        end

        it "does not create a new call off contract" do
          expect { importer.call }.to not_change(CallOffContract, :count)
        end

        it "does not create participant bands" do
          expect { importer.call }.to not_change(ParticipantBand, :count)
        end
      end

      context "when no call off contract exists for lead provider" do
        let!(:cohort) { create(:cohort, start_year: 2024) }
        let!(:lead_provider) { create(:lead_provider, name: "Butterfly Institute", cohorts: [cohort]) }
        before do
          csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{cohort.start_year},0.44,200,4600,4790,0,2300,0,90,895,91,199,700,200,299,600,300,400,500"
          csv.write "\n"
          csv.close
        end
        let(:created_call_off_contract) { CallOffContract.last }

        it "creates a new call off contract" do
          expect { importer.call }.to change(CallOffContract, :count).by(1)
        end

        it "sets the call off contract version" do
          importer.call
          expect(created_call_off_contract.version).to eq("0.0.1")
        end

        it "sets the correct values on the call off contract" do
          importer.call
          expect(created_call_off_contract).to have_attributes(
            cohort:,
            uplift_target: 0.44,
            uplift_amount: 200,
            recruitment_target: 4600,
            revised_target: 4790,
            set_up_fee: 0,
            monthly_service_fee: 2300,
          )
        end

        it "creates 4 participant bands" do
          expect { importer.call }.to change(ParticipantBand, :count).by(4)
        end

        it "sets the correct values on band a" do
          importer.call
          expect(created_call_off_contract.band_a).to have_attributes(
            min: 0,
            max: 90,
            per_participant: 895,
            output_payment_percentage: 60,
            service_fee_percentage: 40,
          )
        end

        it "sets the correct values on band b" do
          importer.call
          expect(created_call_off_contract.bands.order(max: :asc).second).to have_attributes(
            min: 91,
            max: 199,
            per_participant: 700,
            output_payment_percentage: 60,
            service_fee_percentage: 40,
          )
        end

        it "sets the correct values on band c" do
          importer.call
          expect(created_call_off_contract.bands.order(max: :asc).third).to have_attributes(
            min: 200,
            max: 299,
            per_participant: 600,
            output_payment_percentage: 60,
            service_fee_percentage: 40,
          )
        end

        it "sets the correct values on band d" do
          importer.call
          expect(created_call_off_contract.bands.order(max: :asc).fourth).to have_attributes(
            min: 300,
            max: 400,
            per_participant: 500,
            output_payment_percentage: 100,
            service_fee_percentage: 0,
          )
        end
      end
    end

    context "when call off contract has no band D to be created" do
      let!(:cohort) { create(:cohort, start_year: 2024) }
      let!(:lead_provider) { create(:lead_provider, name: "Butterfly Institute", cohorts: [cohort]) }
      before do
        csv.write "lead-provider-name,cohort-start-year,uplift-target,uplift-amount,recruitment-target,revised-target,set-up-fee,monthly-service-fee,band-a-min,band-a-max,band-a-per-participant,band-b-min,band-b-max,band-b-per-participant,band-c-min,band-c-max,band-c-per-participant,band-d-min,band-d-max,band-d-per-participant"
        csv.write "\n"
        csv.write "#{lead_provider.name},#{cohort.start_year},0.44,200,4600,4790,0,2300,0,90,895,91,199,700,200,299,600,,,"
        csv.write "\n"
        csv.close
      end
      let(:created_call_off_contract) { CallOffContract.last }

      it "creates 3 participant bands" do
        importer.call

        expect(created_call_off_contract.band_a).to be_present
        expect(created_call_off_contract.bands.order(max: :asc).second).to be_present
        expect(created_call_off_contract.bands.order(max: :asc).third).to be_present
        expect(created_call_off_contract.bands.order(max: :asc).fourth).to be_nil
      end
    end
  end
end
