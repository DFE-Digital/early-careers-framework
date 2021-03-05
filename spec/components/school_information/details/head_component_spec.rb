# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::Details::HeadComponent, type: :component do
  let(:school){ create(:school) }
  let(:selected_cohort){ create(:cohort, start_year: 2021) }
  let(:rendered_component){ render_inline(described_class.new(school: school, selected_cohort: selected_cohort)).to_html }

  it 'contains the name of the school' do
    expect(rendered_component).to include school.name
  end

  it 'contains correct cohort recruitment text' do
    expect(rendered_component).to include "#{selected_cohort.start_year} recruitment"
  end
end
