# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::SchoolProfile", type: :request do
  describe "GET /registrations/school-profile" do
    it "renders the show template" do
      get "/registrations/school-profile"
      expect(response).to render_template("registrations/school_profile/show")
    end
  end

  describe "POST /registrations/school-profile" do
    let(:school) { FactoryBot.create(:school) }
    let(:email) { Faker::Internet.email }
    let(:urn) { school.urn }

    it "redirects to user-profile if the urn is valid" do
      post "/registrations/school-profile", params: { school_profile_form: {
        urn: urn,
      } }

      expect(response).to redirect_to(:new_registrations_user_profile)
    end

    context "when the school is ineligible" do
      before do
        allow_any_instance_of(School).to receive(:eligible?).and_return(false)
      end

      it "redirects to the school-not-eligible page" do
        post "/registrations/school-profile", params: { school_profile_form: {
          urn: urn,
        } }

        expect(school.eligible?).to be false
        expect(response).to redirect_to(:registrations_school_not_eligible)
      end
    end

    context "when the school is already fully registered" do
      before do
        user = create(:user, confirmed_at: 2.days.ago)
        create(:induction_coordinator_profile, user: user, schools: [school])
      end

      it "redirects to school-registered" do
        post "/registrations/school-profile", params: { school_profile_form: {
          urn: urn,
        } }

        expect(response).to redirect_to(:registrations_school_registered)
      end
    end

    context "when the school is registration has not been confirmed" do
      before do
        user = create(:user, confirmed_at: nil)
        create(:induction_coordinator_profile, user: user, schools: [school])
      end

      it "redirects to school-not-confimed" do
        post "/registrations/school-profile", params: { school_profile_form: {
          urn: urn,
        } }

        expect(response).to redirect_to(:registrations_school_not_confirmed)
      end
    end

    context "when the school urn does not match a school" do
      it "renders an error message" do
        post "/registrations/school-profile", params: { school_profile_form: {
          urn: "980567",
        } }

        expect(response.body).to include("No school matched that URN")
        expect(response).to render_template("registrations/school_profile/show")
      end
    end

    context "when the school urn is missing" do
      it "renders an error message" do
        post "/registrations/school-profile", params: { school_profile_form: {
          urn: "",
        } }

        expect(response.body).to include("Enter a school URN")
        expect(response).to render_template("registrations/school_profile/show")
      end
    end
  end
end
