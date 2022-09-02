# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::ECFStatementSelector, type: :component do
  let!(:lead_provider) { create(:lead_provider) }
  let!(:ecf_statement) { create(:ecf_statement) }
  let!(:other_ecf_statement) { create(:ecf_statement) }

  let(:cohorts) { Cohort.where(start_year: 2021..) }

  let(:rendered) { render_inline(described_class.new(current_statement: ecf_statement, cohorts:)) }

  it "has a form that PUTs to correct action" do
    expect(rendered).to have_selector("form[method=post][action='/finance/payment-breakdowns/choose-ecf-statement']")
  end

  it "has dropdown with ECF lead providers" do
    expect(rendered).to have_selector("select#lead-provider-field")
    expect(rendered).to have_selector("select#lead-provider-field option[value='#{lead_provider.id}']", text: lead_provider.name)
  end

  it "has dropdown with statements" do
    expect(rendered).to have_selector("select#statement-field")
    expect(rendered).to have_selector("select#statement-field option[value='#{ecf_statement.name.parameterize}']", text: ecf_statement.name)
  end

  it "has submit button" do
    expect(rendered).to have_selector("button[type=submit]")
  end

  it "defaults selected lead provider to current lead provider" do
    expect(rendered).to have_selector("select#lead-provider-field option[selected]", text: ecf_statement.lead_provider.name, visible: false)
  end

  it "defaults selected statement to current statement" do
    expect(rendered).to have_selector("select#statement-field option[selected]", text: ecf_statement.name, visible: false)
  end
end
