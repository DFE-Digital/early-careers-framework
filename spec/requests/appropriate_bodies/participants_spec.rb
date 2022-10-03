# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AppropriateBodies::Participants", type: :request do
  let(:user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { user.appropriate_bodies.first }

  before do
    sign_in user
  end

  describe "GET appropriate-bodies/participants" do
    it "renders the index participants template" do
      get "/appropriate-bodies/#{appropriate_body.id}/participants"
      expect(response).to render_template "appropriate_bodies/participants/index"
    end
  end

  describe "Unauthorised user" do
    let(:user) { create(:user) }

    it "raises not authorised error" do
      expect {
        get "/appropriate-bodies"
      }.to raise_error Pundit::NotAuthorizedError
    end
  end
end
