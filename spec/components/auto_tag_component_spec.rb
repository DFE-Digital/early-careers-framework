# frozen_string_literal: true

require "rails_helper"

RSpec.describe AutoTagComponent, type: :component do
  it "renders yellow tag for to do" do
    render_inline(described_class.new(text: "To do")).to_html
    expect(rendered_content).to include("To do")
    expect(rendered_content).to include("yellow")
  end

  it "renders green tag for done" do
    render_inline(described_class.new(text: "Done")).to_html
    expect(rendered_content).to include("Done")
    expect(rendered_content).to include("green")
  end

  it "renders grey tag for unknown" do
    render_inline(described_class.new(text: "Test string")).to_html
    expect(rendered_content).to include("Test string")
    expect(rendered_content).to include("grey")
  end
end
