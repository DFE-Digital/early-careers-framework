# frozen_string_literal: true

require "rails_helper"

describe "ApiAuditable", type: :controller do
  controller(ApplicationController) do
    include ApiAuditable
    skip_before_action :capture_params, only: :base_action

    def audited_action
      render json: { params: params.except(:action).to_s }
    end

    def base_action
      render json: { params: params.except(:action).to_s }
    end
  end

  before do
    routes.draw do
      get "audited_action" => "anonymous#audited_action"
      post "audited_action" => "anonymous#audited_action"
      get "base_action" => "anonymous#base_action"
      post "base_action" => "anonymous#base_action"
    end
  end

  describe "capture_params" do
    it "preserves params for get requests" do
      get("base_action")
      baseline_get = response.body
      get("audited_action")
      audited_get = response.body
      expect(baseline_get).to eq(audited_get)
    end

    it "stores the path for get requests" do
      get("audited_action")

      expect(ApiRequestAudit.order(created_at: :asc).last.body).to eq ""
      expect(ApiRequestAudit.order(created_at: :asc).last.path).to eq "/audited_action"
    end

    it "preserves params for post requests" do
      params = { test_key: :test_value }

      post("base_action", params: params)
      baseline_post = response.body

      post("audited_action", params: params)
      audited_post = response.body

      expect(baseline_post).to eq(audited_post)
    end

    it "stores the path for post requests" do
      params = { test_key: :test_value, test_hash: { test_hash_key: "test hash value" } }

      post "audited_action", body: params.to_json

      expect(ApiRequestAudit.order(created_at: :asc).last.body.to_s).to eq params.to_json
      expect(ApiRequestAudit.order(created_at: :asc).last.path).to eq "/audited_action"
    end
  end
end
