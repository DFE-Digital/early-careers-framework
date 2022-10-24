# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::Table, type: :component do
  include Pagy::Backend

  let(:items) { 10 }
  let(:partnerships) { create_list(:partnership, 21) }
  let(:page) { rand(1..2) }

  let(:component) { described_class.new partnerships:, page: }
  subject! { render_inline(component) }

  it "renders table row for each school" do
    expected_partnerships = partnerships.each_slice(items).to_a[page - 1]
    unexpected_partnerships = partnerships - expected_partnerships

    expect(rendered_content).to have_css(".govuk-table__body > .govuk-table__row", count: expected_partnerships.size)
    expect(rendered_content).to include(*expected_partnerships.map(&:school).map(&:urn))
    expect(rendered_content).not_to include(*unexpected_partnerships.map(&:school).map(&:urn))
  end
end
