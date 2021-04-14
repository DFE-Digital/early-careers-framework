# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decorators::SchoolDecorator do
  let(:school) { create(:school, name: "Western Armstrong", address_line1: "52634 Gloria Circle", address_line2: "Pagac Extensions", postcode: "SE23 1SA") }
  let(:school_decorator) { Decorators::SchoolDecorator.new(school) }

  describe "#name_with_address" do
    let(:expected_name_with_address) do
      "#{school.name} (#{school_decorator.full_address_formatted})"
    end
    it "returns the school name with an appended address" do
      expect(school_decorator.name_with_address).to eq expected_name_with_address
    end
  end

  describe "#full_address_formatted" do
    it "outputs correctly formatted full address string" do
      expect(school_decorator.full_address_formatted).to eq "52634 Gloria Circle, Pagac Extensions, SE23 1SA"
    end
  end
end
