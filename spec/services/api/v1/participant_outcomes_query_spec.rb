# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ParticipantOutcomesQuery do
  let(:provider_declaration) { create_declaration }
  let!(:provider_outcomes) { create_outcomes(provider_declaration, date: 3.days.ago) }
  let(:other_provider_declaration) { create_declaration }
  let!(:other_provider_outcomes) { create_outcomes(other_provider_declaration, date: 2.days.ago) }

  describe "#scope" do
    context "for lead provider only" do
      subject(:index) { described_class.new(cpd_lead_provider: provider_declaration.cpd_lead_provider) }

      it "returns all declarations outcomes for the provider" do
        expect(index.scope.to_a).to eq(provider_outcomes)
      end

      it "returns outcomes across multiple declarations" do
        other_provider_declaration.update!(cpd_lead_provider: provider_declaration.cpd_lead_provider)
        expect(index.scope.to_a).to eq(provider_outcomes + other_provider_outcomes)
      end
    end

    context "when participant_id is supplied" do
      subject!(:index) do
        described_class.new(
          cpd_lead_provider: provider_declaration.cpd_lead_provider,
          participant_external_id: provider_declaration.participant_profile.participant_identity.external_identifier,
        )
      end

      it "returns outcomes for the participant" do
        expect(index.scope.to_a).to eq(provider_outcomes)
      end

      it "does not return outcomes for other participants" do
        provider_declaration.update!(participant_profile: other_provider_declaration.participant_profile)
        expect(index.scope.to_a).to be_empty
      end
    end

    context "when created_since filter is supplied" do
      let!(:early_provider_outcomes) { create_outcomes(provider_declaration, date: 3.weeks.ago) }

      subject!(:index) do
        described_class.new(
          cpd_lead_provider: provider_declaration.cpd_lead_provider,
          params: { filter: { created_since: } },
        )
      end

      context "when created_since is earlier than all outcomes" do
        let(:created_since) { (3.weeks + 1.day).ago.iso8601 }

        it { expect(index.scope.to_a).to eq(early_provider_outcomes + provider_outcomes) }
      end

      context "when created_since is later than some outcomes" do
        let(:created_since) { 2.weeks.ago.iso8601 }

        it { expect(index.scope.to_a).to eq(provider_outcomes) }
      end

      context "when created_since is later than all outcomes" do
        let(:created_since) { 1.day.from_now.iso8601 }

        it { expect(index.scope.to_a).to be_empty }
      end

      context "when the created_since is a URL encoded iso8601 date" do
        let(:created_since) { CGI.escape(2.weeks.ago.iso8601) }

        it { expect(index.scope.to_a).to eq(provider_outcomes) }
      end

      context "when created_since is not a valid date" do
        let(:created_since) { "yesterday" }

        it { expect { index.scope }.to raise_error(Api::Errors::InvalidDatetimeError, "The filter '#/created_since' must be a valid RCF3339 date") }
      end
    end
  end

private

  def create_declaration
    provider = create(:cpd_lead_provider, :with_npq_lead_provider)
    npq_application = create(:npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider)
    create(:npq_participant_declaration,
           participant_profile: npq_application.profile,
           cpd_lead_provider: provider)
  end

  def create_outcomes(declaration, date: Time.zone.now)
    travel_to(date) do
      [
        create(:participant_outcome, :failed, participant_declaration: declaration),
        create(:participant_outcome, :passed, participant_declaration: declaration),
        create(:participant_outcome, :voided, participant_declaration: declaration),
      ]
    end
  end
end
