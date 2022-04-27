# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ParticipantDeclarations::Index do
  describe "#scope" do
    context "when new provider querying" do
      let(:old_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:new_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

      let(:old_lead_provider) { old_cpd_lead_provider.lead_provider }
      let(:new_lead_provider) { new_cpd_lead_provider.lead_provider }

      let(:old_partnership) { create(:partnership, lead_provider: old_lead_provider) }
      let(:new_partnership) { create(:partnership, lead_provider: new_lead_provider) }
      let(:old_induction_programme) do
        create(
          :induction_programme,
          :fip,
          partnership: old_partnership,
        )
      end

      let(:new_induction_programme) do
        create(
          :induction_programme,
          :fip,
          partnership: new_partnership,
        )
      end

      let!(:old_induction_record) do
        Induction::Enrol
          .call(participant_profile: profile, induction_programme: old_induction_programme)
      end

      let!(:new_induction_record) do
        Induction::Enrol
          .call(participant_profile: profile, induction_programme: new_induction_programme)
      end

      let!(:profile) { create(:ect_participant_profile) }
      let(:user) { profile.user }

      let(:old_provider_declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: old_cpd_lead_provider,
          user: user,
          participant_profile: profile,
        )
      end

      let(:old_provider_voided_declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: old_cpd_lead_provider,
          user: user,
          participant_profile: profile,
          state: "voided",
        )
      end

      let(:new_provider_voided_declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: new_cpd_lead_provider,
          user: user,
          participant_profile: profile,
          state: "voided",
        )
      end

      let(:old_provider_ineligible_declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: old_cpd_lead_provider,
          user: user,
          participant_profile: profile,
          state: "ineligible",
        )
      end

      let(:new_provider_ineligible_declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: new_cpd_lead_provider,
          user: user,
          participant_profile: profile,
          state: "ineligible",
        )
      end

      subject { described_class.new(cpd_lead_provider: new_cpd_lead_provider) }

      before do
        profile.induction_records.find_by(induction_programme_id: old_induction_programme.id).leaving!
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
