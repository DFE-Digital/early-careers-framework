# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decorators::SchoolDecorator do
  describe "full address_formatted" do
    let(:school) { create(:school, name: "Western Armstrong", address_line1: "52634 Gloria Circle", address_line2: "Pagac Extensions", postcode: "SE23 1SA") }
    let(:school_decorator) { Decorators::SchoolDecorator.new(school) }
    it "outputs correctly formatted full address string" do
      expect(school_decorator.full_address_formatted).to eq "52634 Gloria Circle, Pagac Extensions, SE23 1SA"
    end
  end
end
