# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cookies API", type: :request do
  describe "PUT /cookies" do
    it "handles analytics cookie acceptance" do
      headers = { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" }
      put "/cookies", params: { "cookies_form": { "analytics_consent": "on" } }.to_json, headers: headers

      expected = { status: "ok", message: "You've accepted analytics cookies." }.to_json
      expect(response.content_type).to include("application/json")
      expect(response.body).to eq(expected)
      expect(response.cookies["cookie_consent_1"]).to eq("on")
    end

    it "handles analytics cookie rejection" do
      headers = { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" }
      put "/cookies", params: { "cookies_form": { "analytics_consent": "off" } }.to_json, headers: headers

      expected = { status: "ok", message: "You've rejected analytics cookies." }.to_json
      expect(response.content_type).to include("application/json")
      expect(response.body).to eq(expected)
      expect(response.cookies["cookie_consent_1"]).to eq("off")
    end

    it "does not affect session[:return_to] variable" do
      get cookies_path

      headers = { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" }
      put "/cookies", params: { "cookies_form": { "analytics_consent": "on" } }.to_json, headers: headers

      expect(session[:return_to]).to eq("http://www.example.com/")
    end
  end

  describe "GET /cookies" do
    let!(:privacy_policy) { create :privacy_policy }
    
    context "from a different page" do
      it "sets the session[:return_to] as previous url" do
        get privacy_policy_path
        expect(session[:return_to]).to eq("http://www.example.com/privacy-policy")
        get cookies_path
        expect(session[:return_to]).to eq("http://www.example.com/privacy-policy")
      end
    end

    context "from the same page with empty session" do
      it "sets the session[:return_to] as root url" do
        get cookies_path
        expect(session[:return_to]).to eq("http://www.example.com/")
      end
    end
  end
end
