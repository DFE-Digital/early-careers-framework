# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts::ChangeProgramme", type: :request do
  let(:partnership) { create(:partnership) }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }

  context "when the user is a super user" do
    before do
      sign_in create(:user, :super_user)
    end

    describe "GET /admin/schools/:school_slug/cohorts/:id/challenge-partnership/new" do
      it "renders the new template" do
        get "/admin/schools/#{school.slug}/partnerships/#{partnership.id}/challenge-partnership/new"
        expect(response).to render_template "admin/schools/cohorts/challenge_partnership/new"
      end
    end

    describe "POST /admin/schools/:school_slug/cohorts/:id/challenge-partnership/confirm" do
      it "shows an error message if no reason is selected" do
        post "/admin/schools/#{school.slug}/partnerships/#{partnership.id}/challenge-partnership/confirm", params: {
          challenge_partnership_form: {
            partnership_id: partnership.id,
            challenge_reason: "",
          },
        }

        expect(response).to render_template "admin/schools/cohorts/challenge_partnership/new"
        expect(response.body).to include "Select a reason why you think this confirmation is incorrect"
      end

      it "shows a confirmation message" do
        post "/admin/schools/#{school.slug}/partnerships/#{partnership.id}/challenge-partnership/confirm", params: {
          challenge_partnership_form: {
            partnership_id: partnership.id,
            lead_provider_name: partnership.lead_provider.name,
            challenge_reason: "mistake",
          },
        }

        expect(response).to render_template "admin/schools/cohorts/challenge_partnership/confirm"
      end
    end

    describe "POST /admin/schools/:school_slug/cohorts/:id/challenge-partnership" do
      it "call Partnerships::Challenge with the correct arguments" do
        expect(Partnerships::Challenge).to receive(:call).with(partnership:, challenge_reason: "mistake")

        post "/admin/schools/#{school.slug}/partnerships/#{partnership.id}/challenge-partnership", params: {
          challenge_partnership_form: {
            partnership_id: partnership.id,
            challenge_reason: "mistake",
          },
        }
      end

      it "redirects to the cohorts page and shows a success message" do
        post "/admin/schools/#{school.slug}/partnerships/#{partnership.id}/challenge-partnership", params: {
          challenge_partnership_form: {
            partnership_id: partnership.id,
            challenge_reason: "mistake",
          },
        }

        expect(response).to redirect_to "/admin/schools/#{school.slug}/cohorts"
        follow_redirect!
        expect(response.body).to include "Induction programme has been challenged"
      end
    end
  end

  context "when the user isn't a superuser" do
    before do
      sign_in create(:user, :admin)
    end

    describe "GET /admin/schools/:school_slug/cohorts/:id/challenge-partnership/new" do
      it "triggers a policy error" do
        path = "/admin/schools/#{school.slug}/partnerships/#{partnership.id}/challenge-partnership/new"
        expect { get(path) }.to raise_error(Pundit::NotAuthorizedError, "not allowed to challenge? this Partnership")
      end
    end
  end
end
