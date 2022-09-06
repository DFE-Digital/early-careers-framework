# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::NPQStatementSelector, type: :component do
  let(:cpd_lead_provider)    { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider)    { cpd_lead_provider.npq_lead_provider }
  let!(:npq_statement)       { create(:npq_statement, cpd_lead_provider:) }
  let!(:other_npq_statement) { create(:npq_statement) }

  let(:rendered) { render_inline(described_class.new(current_statement: npq_statement)) }

  it "has a form that PUTs to correct action" do
    expect(rendered).to have_selector("form[method=post][action='/finance/payment-breakdowns/choose-npq-statement']")
  end

  it "has dropdown with NPQ lead providers" do
    expect(rendered).to have_selector("select#npq-lead-provider-field")
    expect(rendered).to have_selector("select#npq-lead-provider-field option[value='#{npq_lead_provider.id}']", text: npq_lead_provider.name)
  end

  it "has dropdown with statements" do
    expect(rendered).to have_selector("select#statement-field")
    expect(rendered).to have_selector("select#statement-field option[value='#{npq_statement.name.parameterize}']", text: npq_statement.name)
  end

  it "has submit button" do
    expect(rendered).to have_selector("button[type=submit]")
  end

  it "defaults selected lead provider to current lead provider" do
    expect(rendered).to have_selector("select#npq-lead-provider-field option[selected]", text: npq_statement.npq_lead_provider.name, visible: false)
  end

  it "defaults selected statement to current statement" do
    expect(rendered).to have_selector("select#statement-field option[selected]", text: npq_statement.name, visible: false)
  end
end
