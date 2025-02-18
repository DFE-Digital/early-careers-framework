# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ECF::AssuranceReport::CsvSerializer do
  let(:statement) { create(:ecf_statement) }
  let(:query) { Finance::ECF::AssuranceReport::Query.new(statement) }
  let(:scope) { query.participant_declarations }
  let(:instance) { described_class.new(scope, statement) }

  describe "#filename" do
    let(:lead_provider_name) { statement.lead_provider.name.gsub(/\W/, "") }
    let(:cohort_start_year) { statement.cohort.start_year }
    let(:statement_name) { statement.name.gsub(/\W/, "") }

    subject { instance.filename }

    it { is_expected.to eq("ECF-Declarations-#{lead_provider_name}-Cohort#{cohort_start_year}-#{statement_name}.csv") }
  end

  describe "#call" do
    subject(:parsed_csv) { CSV.parse(instance.call, headers: true).map(&:to_h) }

    it { expect { parsed_csv }.not_to raise_error }

    context "when there are declarations" do
      let(:statement) { declaration.statements.sample }
      let(:declaration) { create(:ect_participant_declaration, :payable) }
      let(:declaration_csv) { parsed_csv.first }

      it { expect(parsed_csv.size).to eq(1) }

      it "populates the CSV with the declaration data" do
        declaration_details = scope.first

        expect(parsed_csv).to include({
          "Participant ID" => declaration_details.participant_id,
          "Participant Name" => declaration_details.participant_name,
          "TRN" => declaration_details.trn,
          "Type" => declaration_details.participant_type,
          "Mentor Profile ID" => declaration_details.mentor_profile_id,
          "Schedule" => declaration_details.schedule,
          "Eligible For Funding" => declaration_details.eligible_for_funding.to_s,
          "Eligible For Funding Reason" => declaration_details.eligible_for_funding_reason,
          "Sparsity Uplift" => declaration_details.sparsity_uplift.to_s,
          "Pupil Premium Uplift" => declaration_details.pupil_premium_uplift.to_s,
          "Sparsity And Pp" => declaration_details.sparsity_and_pp.to_s,
          "Lead Provider Name" => declaration_details.lead_provider_name,
          "Delivery Partner Name" => declaration_details.delivery_partner_name,
          "School Urn" => declaration_details.school_urn,
          "School Name" => declaration_details.school_name,
          "Training Status" => declaration_details.training_status,
          "Training Status Reason" => declaration_details.training_status_reason,
          "Declaration ID" => declaration_details.declaration_id,
          "Declaration Status" => declaration_details.declaration_status,
          "Declaration Type" => declaration_details.declaration_type,
          "Declaration Date" => declaration_details.declaration_date.iso8601,
          "Declaration Created At" => declaration_details.declaration_created_at.iso8601,
          "Statement Name" => declaration_details.statement_name,
          "Statement ID" => declaration_details.statement_id,
          "Uplift Payable" => (declaration_details.sparsity_uplift || declaration_details.pupil_premium_uplift).to_s,
        })
      end

      describe "uplift payable" do
        let(:declaration) { create(:ect_participant_declaration, :payable, profile_traits: profile_traits + %i[eligible_for_funding]) }
        let(:parsed_csv_uplift_payable) { parsed_csv.first["Uplift Payable"] }

        context "when sparsity_uplift and pupil_premium_uplift are both false" do
          let(:profile_traits) { [] }

          it { expect(parsed_csv_uplift_payable).to eq("false") }
        end

        context "when sparsity_uplift and pupil_premium_uplift are both true" do
          let(:profile_traits) { %i[pupil_premium_and_sparsity_uplift] }

          it { expect(parsed_csv_uplift_payable).to eq("true") }
        end

        context "when sparsity_uplift is true and pupil_premium_uplift is false" do
          let(:profile_traits) { %i[sparsity_uplift] }

          it { expect(parsed_csv_uplift_payable).to eq("true") }
        end

        context "when sparsity_uplift is false and pupil_premium_uplift is true" do
          let(:profile_traits) { %i[pupil_premium_uplift] }

          it { expect(parsed_csv_uplift_payable).to eq("true") }
        end
      end
    end
  end
end
