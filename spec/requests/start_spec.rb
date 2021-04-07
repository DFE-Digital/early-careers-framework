# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Start page", type: :request do
  describe "GET /" do
    it "renders the index template" do
      get "/"
      expect(response).to render_template("start/index")
    end
  end
end
