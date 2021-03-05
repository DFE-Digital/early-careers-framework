# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::YourSchools::HeadingComponent, type: :component do
  let(:component){ described_class.new }
  let(:rendered_component){ render_inline(component).to_html }

  it 'includes Your schools text' do
    expect(rendered_component).to include 'Your schools'
  end

  it 'includes Find and add schools text' do
    expect(rendered_component).to include 'Find and add schools'
  end
end
