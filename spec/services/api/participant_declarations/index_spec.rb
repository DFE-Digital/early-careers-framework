# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ParticipantDeclarations::Index do
  describe "#scope" do
    context "when new provider querying" do
      let(:old_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:new_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

      let(:partnership) { create(:partnership, lead_provider: new_cpd_lead_provider.lead_provider) }
      let(:induction_programme) do
        create(
          :induction_programme,
          :fip,
          partnership: partnership,
        )
      end

      let(:profile) { create(:ect_participant_profile) }
      let(:user) { profile.user }

      let(:declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: old_cpd_lead_provider,
          user: user,
          participant_profile: profile,
        )
      end

      subject { described_class.new(cpd_lead_provider: new_cpd_lead_provider) }

      before do
        Induction::Enrol.call(participant_profile: profile, induction_programme: induction_programme)
      end

      it "returns old providers declarations" do
        expect(subject.scope).to include(declaration)
      end
    end
  end
end
