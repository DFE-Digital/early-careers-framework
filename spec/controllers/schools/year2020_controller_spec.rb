# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::Year2020Controller, type: :controller do
  let!(:school) { create :school }

  describe "sets headers" do
    it "robots are asked not to index" do
      get :start, params: { school_id: school.slug }
      expect(response.headers["X-Robots-Tag"]).to eq("noindex")
    end
  end
end
