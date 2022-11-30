# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ParticipantOutcomesQuery, :with_default_schedules do
  describe "#scope" do
    let(:provider_declaration) { create_declaration }
    let!(:provider_outcomes) { create_outcomes(provider_declaration) }
    let(:other_provider_declaration) { create_declaration }
    let!(:other_provider_outcomes) { create_outcomes(other_provider_declaration) }
    subject(:index) { described_class.new(cpd_lead_provider: provider_declaration.cpd_lead_provider) }

    it "returns all declarations outcomes for the provider" do
      expect(index.scope.to_a).to eq(provider_outcomes)
    end

    it "returns outcomes across multiple declarations" do
      other_provider_declaration.update!(cpd_lead_provider: provider_declaration.cpd_lead_provider)
      expect(index.scope.to_a).to eq(provider_outcomes.append(other_provider_outcomes).flatten)
    end

  private

    def create_declaration
      provider = create(:cpd_lead_provider, :with_npq_lead_provider)
      npq_application = create(:npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider)
      create(:npq_participant_declaration,
             participant_profile: npq_application.profile,
             cpd_lead_provider: provider)
    end

    def create_outcomes(declaration)
      [
        create(:participant_outcome, :failed, participant_declaration: declaration),
        create(:participant_outcome, :passed, participant_declaration: declaration),
        create(:participant_outcome, :voided, participant_declaration: declaration),
      ]
    end
  end
end
