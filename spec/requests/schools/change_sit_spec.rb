# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::ChangeSit", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let!(:cohort) { Cohort.current || create(:cohort, :current) }
  let!(:school_cohort) { create(:school_cohort, school:, cohort:) }

  before do
    sign_in user
  end

  describe "GET /schools/:slug/change-sit/name" do
    it "renders the name template" do
      get "/schools/#{school.slug}/change-sit/name"

      expect(response).to render_template "schools/change_sit/name"
    end
  end

  describe "POST /schools/:slug/change-sit/name" do
    it "rejects an empty name" do
      post "/schools/#{school.slug}/change-sit/name", params: { induction_tutor_form: { name: "" } }

      expect(response).to render_template "schools/change_sit/name"
      expect(response.body).to include "Enter a full name"
    end
  end

  describe "GET /schools/:slug/change-sit/email" do
    it "renders the email template" do
      get "/schools/#{school.slug}/change-sit/email"
      expect(response).to render_template "schools/change_sit/email"
    end
  end

  describe "POST /schools/:slug/change-sit/email" do
    it "rejects an empty email" do
      post "/schools/#{school.slug}/change-sit/email", params: { induction_tutor_form: { email: "" } }

      expect(response).to render_template "schools/change_sit/email"
      expect(response.body).to include "Enter an email"
    end
  end

  describe "GET /schools/:slug/change-sit/check-details" do
    it "renders the check details template" do
      get "/schools/#{school.slug}/change-sit/check-details"
      expect(response).to render_template "schools/change_sit/check_details"
    end
  end

  describe "GET /schools/:slug/change-sit/confirm" do
    it "renders the confirm template" do
      get "/schools/#{school.slug}/change-sit/confirm"
      expect(response).to render_template "schools/change_sit/confirm"
    end
  end

  describe "POST /schools/:slug/change-sit/confirm" do
    let(:new_name) { Faker::Name.name }
    let(:new_email) { Faker::Internet.email }

    before do
      set_session(:induction_tutor_form, {
        school_id: school.id,
        full_name: new_name,
        email: new_email,
      })
    end

    it "Creates a new user with the correct details" do
      post "/schools/#{school.slug}/change-sit/confirm"

      created_user = User.find_by(email: new_email)
      expect(created_user.full_name).to eq new_name
    end

    it "assigns the school to the new user" do
      post "/schools/#{school.slug}/change-sit/confirm"

      created_user = User.find_by(email: new_email)
      expect(created_user.schools).to include school
    end

    it "deletes the current user" do
      post "/schools/#{school.slug}/change-sit/confirm"

      expect(User.where(id: user.id)).to be_empty
    end

    context "when the acting user has multiple schools" do
      let(:other_school) { create(:school) }
      before do
        user.induction_coordinator_profile.schools << other_school
      end

      it "removes the school from the acting user" do
        post "/schools/#{school.slug}/change-sit/confirm"

        expect(user.schools).not_to include school
      end

      it "adds the school to the new user" do
        post "/schools/#{school.slug}/change-sit/confirm"

        created_user = User.find_by(email: new_email)
        expect(created_user.schools).to include school
      end

      it "does not delete the acting user" do
        post "/schools/#{school.slug}/change-sit/confirm"

        expect(User.where(id: user.id)).not_to be_empty
      end

      it "redirects to the success page" do
        post "/schools/#{school.slug}/change-sit/confirm"

        expect(response).to redirect_to "/schools/#{school.slug}/change-sit/success"
      end
    end
  end

  describe "GET /schools/:slug/change-sit/success" do
    before do
      let(:new_name) { Faker::Name.name }
      let(:new_email) { Faker::Internet.email }

      before do
        set_session(:induction_tutor_form, {
          school_id: school.id,
          full_name: new_name,
          email: new_email,
        })
      end
    end
  end
end
