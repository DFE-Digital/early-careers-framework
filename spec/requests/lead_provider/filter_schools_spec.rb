# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeadProvider::FilterSchools", type: :request do
  before do
    user = create(:user, :lead_provider)
    sign_in user
  end

  describe "show" do
    it "is expected to render the show template" do
      get "/lead-provider/filter-schools"
      expect(response).to render_template(:show)
    end
  end
end
