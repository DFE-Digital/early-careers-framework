# frozen_string_literal: true

require "rails_helper"

RSpec.describe AnalyticsDataLayer, type: :model do
  subject(:data_layer) { described_class.new }

  describe "#add" do
    it "adds a hash to the analytics data" do
      data_layer.add(urn: "123456")

      expect(data_layer.analytics_data[:urn]).to eq("123456")
    end
  end

  describe "#add_user_info" do
    let(:user) { create(:user) }

    it "adds the user type to the analytics data" do
      data_layer.add_user_info(user)
      expect(data_layer.analytics_data[:userType]).to eq(user.user_type)
    end

    context "when the user is a lead provider" do
      let(:user) { create(:user, :lead_provider) }

      it "add the associated lead provider name to the analytics data" do
        data_layer.add_user_info(user)
        expect(data_layer.analytics_data[:providerName]).to eq(user.lead_provider.name)
      end
    end

    context "when the supplied user is nil" do
      it "does not add anything to the analytics data" do
        data_layer.add_user_info(nil)
        expect(data_layer.analytics_data.key?(:userType)).to be false
      end
    end
  end

  describe "#add_school_info" do
    let(:school) { create(:school) }

    it "adds the school URN to the analytics data" do
      data_layer.add_school_info(school)
      expect(data_layer.analytics_data[:schoolId]).to eq(school.urn)
    end

    context "when the supplied school is nil" do
      it "does not add anything to the analytics data" do
        data_layer.add_school_info(nil)
        expect(data_layer.analytics_data.key?(:schoolId)).to be false
      end
    end
  end

  describe "#to_json" do
    before do
      data_layer.add(schoolId: "012345",
                     providerName: "Super Provider Inc.",
                     errors: { a: "error", b: "bad file" })
    end

    it "returns the analytics data as an array of key value pairs in JSON format" do
      result = JSON.parse(data_layer.to_json)
      expect(result).to match_array [{ "schoolId" => "012345" },
                                     { "providerName" => "Super Provider Inc." },
                                     { "errors" => { "a" => "error", "b" => "bad file" } }]
    end
  end
end
