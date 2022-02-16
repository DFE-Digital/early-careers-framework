# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts::ChallengePartnership", type: :request do
  let(:partnership) { create(:partnership) }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }

  before do
    sign_in create(:user, :admin)
  end

  describe "start" do
    describe "GET /admin/schools/:school_slug/cohorts/:id/challenge-partnership" do
      it "renders the new template" do
        get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership"
        expect(response).to redirect_to "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership/reason"
      end
    end
  end

  describe "steps" do
    before do
      get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership"
    end

    describe "GET /admin/schools/:school_slug/cohorts/:id/challenge-partnership/reason" do
      it "renders the reason template" do
        get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership/reason"
        expect(response).to render_template "admin/schools/cohorts/challenge_partnership/reason"
      end
    end

    describe "PATCH /admin/schools/:school_slug/cohorts/:id/challenge-partnership/reason" do
      it "shows an error message if no reason is selected" do
        patch(
          "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership/reason",
          params: {
            challenge_partnership_form: {
              challenge_reason: "",
            },
          },
        )

        expect(response).to render_template "admin/schools/cohorts/challenge_partnership/reason"
        expect(response.body).to include "Select a reason why you think this confirmation is incorrect"
      end
    end

    describe "GET /admin/schools/:school_slug/cohorts/:id/challenge-partnership/confirm" do
      it "renders the reason template" do
        get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership/confirm"
        expect(response).to render_template "admin/schools/cohorts/challenge_partnership/confirm"
      end
    end
  end

  describe "PATCH /admin/schools/:school_slug/cohorts/:id/challenge-partnership/complete" do
    before do
      get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership"
      allow(Partnerships::Challenge).to receive(:call)
    end

    it "redirects back to cohort page" do
      post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership/complete"
      expect(response).to redirect_to "/admin/schools/#{school.slug}/cohorts"
    end
  end
end
