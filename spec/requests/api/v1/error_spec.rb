# frozen_string_literal: true

require "rails_helper"

class TestController < Api::ApiController
  def not_found_exception
    raise ActiveRecord::RecordNotFound
  end

  def random_error
    raise hell
  end
end

class TestWithAuthController < Api::ApiController
  include ApiTokenAuthenticatable

  def normal_endpoint
    render json: { lovely: :jubly }
  end
end

RSpec.describe "API errors", type: :request, exceptions_app: true do
  before do
    Rails.application.routes.disable_clear_and_finalize = true # preserve original routes
    Rails.application.routes.draw do
      get "/not_found_exception", to: "test#not_found_exception"
      get "/random_error", to: "test#random_error"
      get "/normal_endpoint", to: "test_with_auth#normal_endpoint"
    end
  end

  describe "401 errors" do
    it "responds with a status code of 401 and a json response when a valid token isn't provided" do
      headers = {
        "ACCEPT" => "application/json",
        "CONTENT_TYPE" => "application/json",
      }

      get("/normal_endpoint", headers:)
      expect(response.status).to eq 401
      expect(JSON.parse(response.body)).to eq({
        "error" => "HTTP Token: Access denied",
      })
      expect(response.content_type).to eq "application/vnd.api+json"
    end
  end

  describe "404 errors" do
    it "responds with a status code of 404 and a json response when a not found exception is thrown" do
      headers = {
        "ACCEPT" => "application/json",
        "CONTENT_TYPE" => "application/json",
      }

      get("/not_found_exception", headers:)
      expect(response.status).to eq 404
      expect(response.content_type).to eq "application/vnd.api+json"
      expect(JSON.parse(response.body)).to eq({
        "error" => "Resource not Found",
      })
    end

    it "responds with a status code of 404 and a json response when route is not found" do
      headers = {
        "ACCEPT" => "application/json",
        "CONTENT_TYPE" => "application/json",
      }

      get("/jibberish", headers:)
      expect(response.status).to eq 404
      expect(response.content_type).to include "application/vnd.api+json"
      expect(JSON.parse(response.body)).to eq({
        "error" => "Resource not Found",
      })
    end
  end

  describe "500 errors" do
    it "responds with a status code of 500 and a json response when an unhandled exception is thrown" do
      headers = {
        "ACCEPT" => "application/json",
        "CONTENT_TYPE" => "application/json",
      }

      get("/random_error", headers:)
      expect(response.status).to eq 500
      expect(response.content_type).to eq "application/vnd.api+json"
      expect(JSON.parse(response.body)).to eq({
        "error" => "Internal server error",
      })
    end
  end
end
