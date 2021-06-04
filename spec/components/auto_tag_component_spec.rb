# frozen_string_literal: true

require "rails_helper"

RSpec.describe AutoTagComponent, type: :component do
  it "renders yellow tag for to do" do
    rendered_component = render_inline(described_class.new(text: "To do")).to_html
    expect(rendered_component).to include("To do")
    expect(rendered_component).to include("yellow")
  end

  it "renders green tag for done" do
    rendered_component = render_inline(described_class.new(text: "Done")).to_html
    expect(rendered_component).to include("Done")
    expect(rendered_component).to include("green")
  end

  it "renders grey tag for unknown" do
    rendered_component = render_inline(described_class.new(text: "Test string")).to_html
    expect(rendered_component).to include("Test string")
    expect(rendered_component).to include("grey")
  end

  it "renders nothing if the text is blank" do
    rendered_component = render_inline(described_class.new(text: "")).to_html
    expect(rendered_component).to be_blank
  end
end
