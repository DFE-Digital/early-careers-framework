# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::AssuranceReport::Query, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:statement)         { create(:npq_statement, cpd_lead_provider:) }

  let(:participant_profile)       { create(:npq_participant_profile, :eligible_for_funding, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
  let(:participant_identity)      { participant_profile.participant_identity }
  let!(:participant_declaration)  { travel_to(statement.deadline_date) { create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:) } }

  let(:other_statement)                { create(:npq_statement, cpd_lead_provider:, deadline_date: statement.deadline_date + 1.day) }
  let!(:other_participant_declaration) { travel_to(other_statement.deadline_date) { create(:npq_participant_declaration, cpd_lead_provider:) } }

  let(:other_cpd_lead_provider)                          { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:other_cpd_lead_provider_statement)                { create(:npq_statement, cpd_lead_provider:, deadline_date: statement.deadline_date + 1.day) }
  let!(:other_cpd_lead_provider_participant_declaration) { travel_to(other_cpd_lead_provider_statement.deadline_date) { create(:npq_participant_declaration, cpd_lead_provider:) } }

  subject(:query) { described_class.new(statement) }

  let(:assurance_report) { query.participant_declarations.first }

  describe "#participant_declarations" do
    it "includes the declaration" do
      expect(query.participant_declarations).to eq([participant_declaration])
    end

    it "surfaces the preferred external identifier" do
      participant_declarations = query.participant_declarations
      expect(participant_declarations.first.participant_id).to eq(participant_identity.user_id)
    end

    context "with multiple participant identities" do
      let(:new_participant_identity) do
        create(
          :participant_identity,
          :npq_origin,
          user: participant_profile.user,
          external_identifier: SecureRandom.uuid,
          email: "second_email@example.com",
        )
      end
      before do
        # We ideally should not update the existing participant identity on a profile when a new one is added
        # however, some of the data has this incorrect shape, so we should account for it.
        participant_profile.update!(participant_identity: new_participant_identity)
      end

      it "includes the declaration" do
        expect(query.participant_declarations).to eq([participant_declaration])
      end

      it "surfaces the preferred external identifier" do
        participant_declarations = query.participant_declarations
        expect(participant_declarations.first.participant_id).to eq(participant_identity.user_id)
      end
    end
  end
end
