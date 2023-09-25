# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::ECFDetailsTable, type: :component do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  let(:participant_declaration) do
    create(
      :ect_participant_declaration,
      :eligible,
      cpd_lead_provider:,
    )
  end

  let!(:statement) { participant_declaration.statements.first }

  let(:rendered) { render_inline(described_class.new(statement:)) }

  it "has the correct text" do
    expect(rendered).to have_text("Total starts")
    expect(rendered).to have_text(1)
    expect(rendered).to have_text("Total")
    expect(rendered).to have_text("£6,101.75")
  end
end
