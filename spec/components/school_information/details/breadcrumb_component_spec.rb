# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::Details::BreadcrumbComponent, type: :component do
  let(:selected_cohort) { create(:cohort, start_year: 2021) }
  let(:component) { described_class.new(selected_cohort: selected_cohort) }
  let(:render_component) { render_inline(component) }
  let(:before_content_output) { component.content_for(:before_content) }

  before(:each) do
    render_component
  end

  it "includes Schools breadcrumb" do
    expect(before_content_output).to include "Schools"
    expect(before_content_output).to include lead_providers_your_schools_path
  end

  it "includes Cohort breadcrumb" do
    expect(before_content_output).to include "2021 cohort"
    expect(before_content_output).to include lead_providers_your_schools_path(selected_cohort_id: selected_cohort.id)
  end
end
