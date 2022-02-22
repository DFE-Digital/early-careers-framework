# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::StatementSelector, type: :component do
  let!(:npq_lead_provider) { create(:npq_lead_provider) }
  let!(:npq_statement) { create(:npq_statement) }

  let(:rendered) { render_inline(described_class.new) }

  it "has a form that PUTs to correct action" do
    expect(rendered).to have_selector("form[method=post][action='/finance/payment-breakdowns/choose-npq-statement']")
  end

  it "has dropdown with NPQ lead providers" do
    expect(rendered).to have_selector("select#npq-lead-provider-field")
    expect(rendered).to have_selector("select#npq-lead-provider-field option[value='#{npq_lead_provider.id}']", text: npq_lead_provider.name)
  end

  it "has dropdown with statements" do
    expect(rendered).to have_selector("select#statement-field")
    expect(rendered).to have_selector("select#statement-field option[value='#{npq_statement.identifier}']", text: npq_statement.name)
  end

  it "has submit button" do
    expect(rendered).to have_selector("input[type=submit]")
  end
end
