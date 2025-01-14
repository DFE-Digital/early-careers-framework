# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateMentorCallOffContract do
  let(:csv) { Tempfile.new("data.csv") }
  let(:path_to_csv) { csv.path }

  subject(:importer) { described_class.new(path_to_csv:) }

  describe "#call" do
    context "when no csv given" do
      let(:path_to_csv) {}
      let!(:lead_provider_1) { create(:lead_provider, name: "Penguin Institute") }
      let!(:lead_provider_2) { create(:lead_provider, name: "Apples") }

      it "creates seed mentor call off contracts for all lead providers in three cohorts" do
        expect { importer.call }.to change(MentorCallOffContract, :count).by(6)
      end

      context "when in production env" do
        before do
          allow(Rails).to receive(:env).and_return ActiveSupport::EnvironmentInquirer.new("production")
        end

        it "raises an error and does not create records" do
          expect { importer.call }.to raise_error(RuntimeError, /do not seed default mentor call off contracts in production/i)
          expect(MentorCallOffContract.count).to be_zero
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
          csv.write "lead-provider-name,cohort-start-year,recruitment-target,payment-per-participant"
          csv.write "\n"
          csv.write "Aardvark Institute,2021,9999,333.0"
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
          csv.write "lead-provider-name,cohort-start-year,recruitment-target,payment-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{year_without_cohort},2021,9999,333.0"
          csv.write "\n"
          csv.close
        end

        it "raises an error" do
          expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when lead provider does not belong in supplied cohort" do
        let!(:lead_provider) { create(:lead_provider, name: "Kangaroo Institute", cohorts: []) }
        let!(:cohort) { create :cohort }
        before do
          csv.write "lead-provider-name,cohort-start-year,recruitment-target,payment-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{cohort.start_year},9999,333.0"
          csv.write "\n"
          csv.close
        end

        it "raises an error" do
          expect { importer.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the lead provider has an existing mentor call off contract in the cohort" do
        let!(:cohort) { create :seed_cohort }
        let!(:lead_provider) { create(:lead_provider, name: "Whale Institute", cohorts: [cohort]) }
        let!(:mentor_call_off_contract) { create(:mentor_call_off_contract, cohort:, lead_provider:) }
        before do
          csv.write "lead-provider-name,cohort-start-year,recruitment-target,payment-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{cohort.start_year},9999,333.0"
          csv.write "\n"
          csv.close
        end

        it "does not create a new call off contract" do
          expect { importer.call }.to not_change(MentorCallOffContract, :count)
        end

        it "does not create participant bands" do
          expect { importer.call }.to not_change(ParticipantBand, :count)
        end
      end

      context "when no mentor call off contract exists for lead provider" do
        let!(:cohort) { create :cohort }
        let!(:lead_provider) { create(:lead_provider, name: "Butterfly Institute", cohorts: [cohort]) }
        before do
          csv.write "lead-provider-name,cohort-start-year,recruitment-target,payment-per-participant"
          csv.write "\n"
          csv.write "#{lead_provider.name},#{cohort.start_year},9999,333.0"
          csv.write "\n"
          csv.close
        end

        it "creates a new mentor call off contract" do
          expect { importer.call }.to change(MentorCallOffContract, :count).by(1)
        end

        it "sets the mentor call off contract version" do
          importer.call
          expect(lead_provider.mentor_call_off_contracts.first.version).to eq("0.0.1")
        end

        it "sets the correct values on the mentor call off contract" do
          importer.call
          expect(lead_provider.mentor_call_off_contracts.first).to have_attributes(
            cohort:,
            recruitment_target: 9999,
            payment_per_participant: 333.0,
          )
        end
      end
    end
  end
end
