# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ECF::AssuranceReport::Query, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:statement)         { create(:ecf_statement, cpd_lead_provider:) }

  let(:uplifts)                   { [] }
  let(:participant_profile)       { create(:ect, :eligible_for_funding, uplifts:, lead_provider: cpd_lead_provider.lead_provider) }
  let!(:participant_declaration)  { travel_to(statement.deadline_date) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) } }

  let(:other_statement)                { create(:ecf_statement, cpd_lead_provider:, deadline_date: statement.deadline_date + 1.day) }
  let!(:other_participant_declaration) { travel_to(other_statement.deadline_date) { create(:ect_participant_declaration, cpd_lead_provider:) } }

  let(:other_cpd_lead_provider)                          { create(:cpd_lead_provider, :with_lead_provider) }
  let(:other_cpd_lead_provider_statement)                { create(:ecf_statement, cpd_lead_provider:, deadline_date: statement.deadline_date + 1.day) }
  let!(:other_cpd_lead_provider_participant_declaration) { travel_to(other_cpd_lead_provider_statement.deadline_date) { create(:ect_participant_declaration, cpd_lead_provider:) } }

  subject(:query) { described_class.new(statement) }

  let(:assurance_report) { query.participant_declarations.first }

  describe "#participant_declarations" do
    it "includes the declaration" do
      expect(query.participant_declarations).to eq([participant_declaration])
    end
  end

  describe "#sparsity_and_pp" do
    context "with no uplifts" do
      it "is false" do
        expect(assurance_report).not_to be_sparsity_uplift
        expect(assurance_report).not_to be_pupil_premium_uplift
        expect(assurance_report).not_to be_sparsity_and_pp
      end
    end

    context "with sparsity_uplift" do
      let(:uplifts) { [:sparsity_uplift] }

      it "is false", :aggregate_failures do
        expect(assurance_report).to     be_sparsity_uplift
        expect(assurance_report).not_to be_pupil_premium_uplift
        expect(assurance_report).not_to be_sparsity_and_pp
      end
    end

    context "with pupil_premium_uplift" do
      let(:uplifts) { [:pupil_premium_uplift] }

      it "is false", :aggregate_failures do
        expect(assurance_report).not_to be_sparsity_uplift
        expect(assurance_report).to     be_pupil_premium_uplift
        expect(assurance_report).not_to be_sparsity_and_pp
      end
    end

    context "with sparsity_uplift and pupil_premium_uplift" do
      let(:uplifts) { %i[pupil_premium_and_sparsity_uplift] }

      it "is true", :aggregate_failures do
        expect(assurance_report).to be_pupil_premium_uplift
        expect(assurance_report).to be_sparsity_uplift
        expect(assurance_report).to be_sparsity_and_pp
      end
    end
  end
end
