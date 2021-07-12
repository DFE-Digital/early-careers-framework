# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolSerializer do
  describe "serialization" do
    let(:school) { create(:school, name: "Western Armstrong", address_line1: "52634 Gloria Circle", address_line2: "Pagac Extensions", postcode: "SE23 1SA") }
    let(:decorated_school) { SchoolDecorator.new(school) }
    let(:serialized_school) { SchoolSerializer.render(decorated_school) }

    it "outputs correctly formatted serialized school" do
      expected_json_string = "{\"id\":\"#{school.id}\",\"full_address_formatted\":\"52634 Gloria Circle, Pagac Extensions, SE23 1SA\",\"name\":\"Western Armstrong\"}"
      expect(serialized_school).to eq expected_json_string
    end
  end
end
