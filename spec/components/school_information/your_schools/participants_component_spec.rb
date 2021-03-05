# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::YourSchools::ParticipantsComponent, type: :component do
  let(:component) { described_class.new }
  let(:rendered_component) { render_inline(component).to_html }

  it "includes participant target text" do
    expect(rendered_component).to include "participant target"
  end

  it "includes participants added by schools text" do
    expect(rendered_component).to include "participants added by schools"
  end
end
