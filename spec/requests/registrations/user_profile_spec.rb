# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::UserProfile", type: :request do
  let(:school) { create(:school) }
  let(:full_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:session) { { school_urn: school.urn } }
  let(:created_user) { User.find_by_email(email) }

  before do
    allow_any_instance_of(Registrations::UserProfileController)
      .to receive(:session)
      .and_return(session)
  end

  describe "GET /registrations/user-profile/new" do
    it "renders the show template" do
      get "/registrations/user-profile/new"
      expect(response).to render_template("registrations/user_profile/new")
    end
  end

  describe "POST /registrations/user-profile" do
    it "creates an induction coordinator profile" do
      post "/registrations/user-profile", params: { user: {
        full_name: full_name,
        email: email,
      } }

      expect(created_user.full_name).to eq(full_name)
      expect(response).to redirect_to(:registrations_verification_sent)
      expect(created_user.induction_coordinator_profile.schools).to include(school)
    end

    context "when email is missing" do
      it "does not create the user" do
        expect {
          post "/registrations/user-profile", params: { user: {
            full_name: full_name,
          } }
        }.not_to(change { User.count })
        expect(response.body).to include("Enter an email")
        expect(response).to render_template("registrations/user_profile/new")
      end
    end

    context "when full name is missing" do
      it "does not create the user" do
        expect {
          post "/registrations/user-profile", params: { user: {
            email: email,
          } }
        }.not_to(change { User.count })
        expect(response.body).to include("Enter your full name")
        expect(response).to render_template("registrations/user_profile/new")
      end
    end

    context "when the school urn is missing" do
      before do
        allow_any_instance_of(Registrations::UserProfileController)
          .to receive(:session)
          .and_return({})
      end

      it "returns a bad request error" do
        expect {
          post "/registrations/user-profile", params: { user: {
            full_name: full_name,
            email: email,
          } }
        }.to raise_error(ActionController::BadRequest)
      end
    end

    context "when school has old unconfirmed registrations" do
      let(:user) { create(:user, confirmed_at: nil) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      before { user.update(confirmation_sent_at: 2.days.ago) }

      it "registers new induction coordinator and removes the old coordinator profiles" do
        post "/registrations/user-profile", params: { user: {
          full_name: full_name,
          email: email,
        } }

        expect(school.reload.induction_coordinator_profiles).to include created_user.induction_coordinator_profile
        expect(school.induction_coordinator_profiles).not_to include user.reload.induction_coordinator_profile
      end
    end
  end
end
