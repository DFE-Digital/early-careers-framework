# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ParticipantDeclarations::Index do
  describe "#scope" do
    let(:cohort_2021) { Cohort.find_by(start_year: 2021) }

    context "when new provider querying" do
      let(:old_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Old CPD LeadProvider") }
      let(:old_school_cohort)     { create(:school_cohort, :fip, :with_induction_programme, lead_provider: old_cpd_lead_provider.lead_provider, cohort: cohort_2021) }

      let(:new_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "New CPD LeadProvider") }
      let(:new_school_cohort)     { create(:school_cohort, :fip, :with_induction_programme, lead_provider: new_cpd_lead_provider.lead_provider, cohort: cohort_2021) }

      let!(:profile) { create(:ect, :eligible_for_funding, school_cohort: old_school_cohort, lead_provider: old_cpd_lead_provider.lead_provider) }
      let(:user) { profile.user }

      let(:old_provider_declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: old_cpd_lead_provider,
          participant_profile: profile,
        )
      end

      let(:old_provider_voided_declaration) do
        create(
          :ect_participant_declaration,
          :voided,
          declaration_type: "retained-1",
          cpd_lead_provider: old_cpd_lead_provider,
          participant_profile: profile,
        )
      end

      let(:old_provider_ineligible_declaration) do
        create(
          :ect_participant_declaration,
          :ineligible,
          declaration_type: "retained-2",
          cpd_lead_provider: old_cpd_lead_provider,
          participant_profile: profile,
        )
      end

      let(:new_provider_voided_declaration) do
        create(
          :ect_participant_declaration,
          :voided,
          declaration_type: "retained-3",
          cpd_lead_provider: new_cpd_lead_provider,
          participant_profile: profile,
        )
      end

      let(:new_provider_ineligible_declaration) do
        create(
          :ect_participant_declaration,
          :ineligible,
          declaration_type: "retained-3",
          cpd_lead_provider: new_cpd_lead_provider,
          participant_profile: profile,
        )
      end

      subject { described_class.new(cpd_lead_provider: new_cpd_lead_provider) }

      before do
        old_provider_declaration
        old_provider_voided_declaration
        old_provider_ineligible_declaration

        Induction::TransferToSchoolsProgramme.call(
          participant_profile: profile,
          induction_programme: new_school_cohort.default_induction_programme,
        )

        profile.reload

        new_provider_voided_declaration
        new_provider_ineligible_declaration
      end

      it "returns old providers declarations" do
        expect(subject.scope).to include(old_provider_declaration)
      end

      it "returns their own voided declarations but not voided declarations made by old provider" do
        expect(subject.scope).not_to include(old_provider_voided_declaration)
        expect(subject.scope).to include(new_provider_voided_declaration)
      end

      it "returns their own ineligible declarations but not ineligible declarations made by old provider" do
        expect(subject.scope).not_to include(old_provider_ineligible_declaration)
        expect(subject.scope).to include(new_provider_ineligible_declaration)
      end
    end
  end
end
