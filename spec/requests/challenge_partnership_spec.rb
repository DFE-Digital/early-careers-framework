# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ChallengePartnership", type: :request do
  let(:partnership) { create(:partnership, :in_challenge_window) }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }

  describe "start" do
    describe "challenging when signed in" do
      let(:sit) { create :induction_coordinator_profile, schools: [school] }

      it "redirects to report step" do
        sign_in sit.user

        get "/report-incorrect-partnership?partnership=#{partnership.id}"
        expect(response).to redirect_to "/report-incorrect-partnership/reason"
      end
    end

    describe "challenging from a partnership notification email" do
      let(:sit) { create :induction_coordinator_profile, schools: [school] }
      let!(:partnership_notification_email) { create :partnership_notification_email, partnership: partnership }

      context "when the token is valid" do
        it "redirects to report step" do
          get "/report-incorrect-partnership?token=#{partnership_notification_email.token}"
          expect(response).to redirect_to "/report-incorrect-partnership/reason"
        end
      end

      context "when the token is expired" do
        let(:partnership) { create :partnership, :outside_challenge_window }

        it "redirects to report step" do
          get "/report-incorrect-partnership?token=#{partnership_notification_email.token}"
          expect(response).to redirect_to "/report-incorrect-partnership/link-expired"
        end
      end

      context "when the partnership is already challenged" do
        let(:partnership) { create :partnership, :challenged }

        it "redirects to report step" do
          get "/report-incorrect-partnership?token=#{partnership_notification_email.token}"
          expect(response).to redirect_to "/report-incorrect-partnership/already-challenged"
        end
      end
    end
  end

  describe "steps" do
    before do
      sit = create :induction_coordinator_profile, schools: [school]
      sign_in sit.user
      get "/report-incorrect-partnership?partnership=#{partnership.id}"
    end

    describe "GET /report-incorrect-partnership/reason" do
      it "renders the reason template" do
        get "/report-incorrect-partnership/reason"
        expect(response).to render_template "challenge_partnerships/reason"
      end
    end

    describe "PATCH /report-incorrect-partnership/reason" do
      it "shows an error message if no reason is selected" do
        patch(
          "/report-incorrect-partnership/reason",
          params: {
            challenge_partnership_form: {
              challenge_reason: "",
            },
          },
        )

        expect(response).to render_template "challenge_partnerships/reason"
        expect(response.body).to include "Select a reason why you think this confirmation is incorrect"
      end

      it "redirects to confirm step" do
        patch(
          "/report-incorrect-partnership/reason",
          params: {
            challenge_partnership_form: {
              challenge_reason: "mistake",
            },
          },
        )

        expect(response).to redirect_to "/report-incorrect-partnership/confirm"
      end
    end

    describe "GET /admin/schools/:school_slug/cohorts/:id/challenge-partnership/confirm" do
      it "renders the reason template" do
        get "/report-incorrect-partnership/confirm"
        expect(response).to render_template "challenge_partnerships/confirm"
      end
    end
    #
    # describe "PATCH /admin/schools/:school_slug/cohorts/:id/challenge-partnership/complete" do
    #   before do
    #     get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership"
    #     allow(Partnerships::Challenge).to receive(:call)
    #
    #   end
    #
    #   it "redirects back to cohort page" do
    #     post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/challenge-partnership/complete"
    #     expect(response).to redirect_to "/admin/schools/#{school.slug}/cohorts"
    #   end
  end
end
