# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::NPQDetailsTable, type: :component, mid_cohort: true do
  let(:cohort)              { Cohort.current || create(:cohort, :current) }
  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider)   { cpd_lead_provider.npq_lead_provider }
  let(:statement)           { create(:npq_statement, cpd_lead_provider:) }
  let(:participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let!(:npq_course)         { create(:npq_leadership_course, identifier: "npq-leading-teaching") }

  let!(:participant_declaration) do
    travel_to statement.deadline_date do
      create(:npq_participant_declaration, :eligible, cpd_lead_provider:, participant_profile:)
    end
  end

  let(:rendered) { render_inline(described_class.new(statement:)) }

  before do
    npq_contract = NPQContract.find_by(npq_lead_provider:, cohort:, npq_course:)
    npq_contract.update!(monthly_service_fee: nil)
  end

  it "has the correct text" do
    expect(rendered).to have_text("Total starts\n          \n            \n              \n                \n                  1")
    expect(rendered).to have_text("Total net VAT\n          £1,372.63")
  end
end
