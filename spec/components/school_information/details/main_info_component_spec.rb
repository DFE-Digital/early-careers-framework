# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::SchoolInformation::Details::MainInfoComponent, type: :component do
  let(:local_authority) { create(:local_authority, name: "York") }
  let(:school) { create(:school) }
  let(:rendered_component) { render_inline(described_class.new(school: school)).to_html }

  context "with local authority assigned" do
    before(:each) do
      create(:school_local_authority, school: school, local_authority: local_authority, start_year: 2021)
    end

    it "Contains School Information text" do
      expect(rendered_component).to include "School information"
    end

    it "Contains URN" do
      expect(rendered_component).to include "URN"
      expect(rendered_component).to include school.urn.to_s
    end

    it "Contains Local Authority" do
      expect(rendered_component).to include "Local authority"
      expect(rendered_component).to include school.local_authority.name.to_s
    end

    it "Contains School contact" do
      expect(rendered_component).to include "School contact"
    end
  end

  context "without local authority assigned" do
    it "Contains Local Authority" do
      expect(rendered_component).to include "Local authority"
      expect(rendered_component).to include "No local authority assigned"
    end
  end
end
