# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Search schools", type: :request do
  describe "index" do
    let(:parsed_response) { JSON.parse(response.body) }

    before :each do
      10.times { |i| create(:school, name: "foooooo", urn: i.to_s, address_line1: "Bermuda Triangle", address_line2: "Narnia", address_line3: "far far away", address_line4: "Milky Way", postcode: "SE23 1SA") }
      create(:school, name: "baaaaaar", urn: "66666")
    end

    it "returns only 10 results" do
      get "/api/school_search", params: { search_key: "foo" }
      expect(parsed_response.count).to eq 10
    end

    it "returns correctly serialized object" do
      get "/api/school_search", params: { search_key: "foo" }
      parsed_response.each do |school_record|
        expect(school_record["full_address_formatted"]).to eq "Bermuda Triangle, Narnia, far far away, Milky Way, SE23 1SA"
      end
    end
  end
end
