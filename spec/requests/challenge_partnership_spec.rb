# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenging a partnership", type: :request do
  describe "GET /report-incorrect-partnership?token=:token" do
    let(:partnership_notification_email) { create(:partnership_notification_email) }

    it "renders the correct template" do
      get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

      expect(response).to render_template("challenge_partnerships/show")
    end

    it "404s if the token is not valid" do
      expect { get "/report-incorrect-partnership", params: { token: "invalid" } }.to raise_error(ActionController::RoutingError)
    end

    context "when the link has expired" do
      let(:partnership_notification_email) { create(:partnership_notification_email, created_at: 4.weeks.ago) }

      it "redirects to link-expired" do
        get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

        expect(response).to redirect_to("/report-incorrect-partnership/link-expired")
      end
    end

    context "when the partnership has already been challenged" do
      let(:partnership_notification_email) { create(:partnership_notification_email, :challenged) }

      it "redirects to already-challenged" do
        get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

        expect(response).to redirect_to("/report-incorrect-partnership/already-challenged")
      end
    end
  end

  describe "GET /report-incorrect-partnership/link-expired" do
    it "renders the correct template" do
      get "/report-incorrect-partnership/link-expired"
      expect(response).to render_template("challenge_partnerships/link_expired")
    end
  end

  describe "GET /report-incorrect-partnership/already-challenged" do
    it "renders the correct template" do
      get "/report-incorrect-partnership/already-challenged"
      expect(response).to render_template("challenge_partnerships/already_challenged")
    end
  end
end
