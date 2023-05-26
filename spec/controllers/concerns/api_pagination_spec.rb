# frozen_string_literal: true

require "rails_helper"

class TestsController < Api::ApiController
  include ApiPagination
end

class Test < ApplicationRecord; end

describe "ApiPagination", type: :controller do
  before do
    routes.append do
      get "index" => "tests#index"
    end
  end

  describe "pagination" do
    let!(:first_school)  { create(:school) }
    let!(:second_school) { create(:school) }
    controller TestsController do
      def index
        render json: { data: paginate(School.order(created_at: :asc)) }
      end
    end

    it "returns the correct items per page" do
      params = { page: { per_page: 1, page: 1 } }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["data"].size).to eq(1)
      expect(get_response["data"].first["id"]).to eq(first_school.id)
    end

    it "returns the correct items according to page number" do
      params = { page: { per_page: 1, page: 2 } }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["data"].size).to eq(1)
      expect(get_response["data"].first["id"]).to eq(second_school.id)
    end

    it "returns an error with invalid page params" do
      params = { page: { per_page: 1, page: "pageNum" } }
      get("index", params:)

      expect(response).not_to be_successful
      expect(response).to have_http_status(:bad_request)
    end

    it "returns an error with invalid per page params" do
      params = { page: { per_page: "pageNum", page: 1 } }
      get("index", params:)

      expect(response).not_to be_successful
      expect(response).to have_http_status(:bad_request)
    end
  end
end
