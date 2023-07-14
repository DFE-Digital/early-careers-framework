# frozen_string_literal: true

require "rails_helper"

class TestsController < Api::ApiController
  include ApiOrderable
end

class Test < ApplicationRecord; end
class OtherTest < ApplicationRecord; end

describe "ApiOrderable", type: :controller do
  before do
    allow(Test).to receive(:attribute_names).and_return(%w[id full_name])
    allow(OtherTest).to receive(:attribute_names).and_return(%w[email])

    routes.append do
      get "index" => "tests#index"
    end
  end

  describe "sort_params" do
    controller TestsController do
      def index
        render json: { ordering_params: sort_params }
      end
    end

    it "returns formatted sort params relative to the inferred model" do
      params = { sort: "-full_name,id,invalid" }
      get("index", params:)
      get_response = JSON.parse(response.body)

      expect(get_response["ordering_params"]).to eq("tests.full_name DESC, tests.id ASC")
    end

    it "returns nil when there are no sort parameters" do
      get("index")
      get_response = JSON.parse(response.body)

      expect(get_response["ordering_params"]).to be_nil
    end

    context "when the model is specified" do
      controller TestsController do
        def index
          render json: { ordering_params: sort_params(model: OtherTest) }
        end
      end

      it "returns formatted sort params relative to the specified model" do
        params = { sort: "-email,-id" }
        get("index", params:)
        get_response = JSON.parse(response.body)

        expect(get_response["ordering_params"]).to eq("other_tests.email DESC")
      end
    end
  end
end
