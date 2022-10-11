# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::AssuranceReport::Query, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:statement)         { create(:npq_statement, cpd_lead_provider:) }

  let(:participant_profile)       { create(:npq_participant_profile, :eligible_for_funding, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
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
  end
end
