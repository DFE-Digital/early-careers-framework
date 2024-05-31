# frozen_string_literal: true

require "rails_helper"

class FakeSchool
  include GiasTypes
end

describe "GiasTypes" do
  describe "ELIGIBLE_TYPE_CODES" do
    it "matches the old hardcoded list" do
      no_longer_used_codes = [47, 48]

      expect(FakeSchool::ELIGIBLE_TYPE_CODES + no_longer_used_codes).to match_array([1, 2, 3, 5, 6, 7, 8, 12, 14, 15, 18, 28, 31, 32, 33, 34, 35, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 57])
    end
  end

  describe "CIP_ONLY_TYPE_CODES" do
    it "matches the old hardcoded list" do
      expect(FakeSchool::CIP_ONLY_TYPE_CODES).to match_array([10, 11, 30, 37])
    end
  end

  describe "CIP_ONLY_EXCEPT_WELSH_CODES" do
    it "matches the old hardcoded list" do
      expect(FakeSchool::CIP_ONLY_EXCEPT_WELSH_CODES).to match_array([10, 11, 37])
    end
  end

  describe "INDEPENDENT_SCHOOLS_TYPE_CODES" do
    it "matches the old hardcoded list" do
      expect(FakeSchool::INDEPENDENT_SCHOOLS_TYPE_CODES).to match_array([10, 11])
    end
  end
end
