# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::Details::MainInfoComponent, type: :component do
  let(:school){ create(:school) }
  let(:rendered_component){ render_inline(described_class.new(school: school)).to_html }

  it 'Contains School Information text' do
    expect(rendered_component).to include "School information"
  end

  it 'Contains URN' do
    expect(rendered_component).to include "URN"
    expect(rendered_component).to include "#{school.urn}"
  end

  it 'Contains Local Authority' do
    expect(rendered_component).to include "Local authority"
  end

  it 'Contains School contact' do
    expect(rendered_component).to include "School contact"
  end
end
