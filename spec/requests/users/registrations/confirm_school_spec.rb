# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations /school_confirmation", type: :request do
  let(:school) { FactoryBot.create(:school) }

  describe "GET /users/confirm_school" do
    it "renders the correct template for a single school" do
      get "/users/confirm_school", params: { school_ids: [school.id] }
      expect(response).to render_template(:confirm_school)
      expect(response).to render_template(:_single_school)
    end

    it "displays the name of the passed school" do
      get "/users/confirm_school", params: { school_ids: [school.id] }
      expect(response.body).to include(school.name)
    end

    it "renders the correct template for a multiple schools" do
      second_school = FactoryBot.create(:school)
      get "/users/confirm_school", params: { school_ids: [school.id, second_school.id] }
      expect(response).to render_template(:confirm_school)
      expect(response).to render_template(:_multiple_schools)
    end

    it "displays the names of all the passed schools" do
      second_school = FactoryBot.create(:school)
      get "/users/confirm_school", params: { school_ids: [school.id, second_school.id] }
      expect(response.body).to include(school.name)
      expect(response.body).to include(second_school.name)
    end
  end
end
