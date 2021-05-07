# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenging a partnership", type: :request do
  let(:partnership_notification_email) { create(:partnership_notification_email) }
  let(:partnership) { partnership_notification_email.partnerable }
  let(:induction_coordinator) { create(:user, :induction_coordinator, schools: [partnership.school]) }

  describe "GET /report-incorrect-partnership?token=:token" do
    it "renders the challenge partnership template" do
      get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

      expect(response).to render_template("challenge_partnerships/show")
    end

    it "404s if the token is not valid" do
      expect { get "/report-incorrect-partnership", params: { token: "invalid" } }.to raise_error(ActionController::RoutingError)
    end

    context "when the link has expired" do
      let!(:partnership) { create(:partnership) }
      let!(:partnership_notification_email) { create(:partnership_notification_email, partnerable: partnership) }

      it "redirects to link-expired" do
        travel 4.weeks
        get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

        expect(response).to redirect_to("/report-incorrect-partnership/link-expired")
      end
    end

    context "when the partnership has already been challenged" do
      let!(:partnership_notification_email) { create(:partnership_notification_email, :challenged) }

      it "redirects to already-challenged" do
        get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

        expect(response).to redirect_to(/\/report-incorrect-partnership\/already-challenged\?school_name=.*/)
      end

      it "redirects to already-challenged even if the token has expired" do
        travel 15.days
        get "/report-incorrect-partnership", params: { token: partnership_notification_email.token }

        expect(response).to redirect_to(/\/report-incorrect-partnership\/already-challenged\?school_name=.*/)
      end
    end
  end

  describe "GET /report-incorrect-partnership?partnership=:partnership" do
    before do
      sign_in induction_coordinator
    end

    it "renders the challenge partnership template" do
      get "/report-incorrect-partnership", params: { partnership: partnership.id }

      expect(response).to render_template("challenge_partnerships/show")
    end

    context "when the partnership cannot be challenged" do
      let!(:partnership) { create(:partnership) }

      it "redirects to link-expired" do
        travel 4.weeks
        get "/report-incorrect-partnership", params: { partnership: partnership.id }

        expect(response).to redirect_to("/report-incorrect-partnership/link-expired")
      end
    end

    context "when the partnership has already been challenged" do
      let!(:partnership) { create(:partnership, :challenged) }

      it "redirects to already-challenged" do
        get "/report-incorrect-partnership", params: { partnership: partnership.id }

        expect(response).to redirect_to(/\/report-incorrect-partnership\/already-challenged\?school_name=.*/)
      end

      it "redirect to already-challenged even if it is outside the challenge window" do
        travel 15.days
        get "/report-incorrect-partnership", params: { partnership: partnership.id }

        expect(response).to redirect_to(/\/report-incorrect-partnership\/already-challenged\?school_name=.*/)
      end
    end
  end

  describe "GET /report-incorrect-partnership/link-expired" do
    it "renders the link expired template" do
      get "/report-incorrect-partnership/link-expired"
      expect(response).to render_template("challenge_partnerships/link_expired")
    end
  end

  describe "GET /report-incorrect-partnership/already-challenged" do
    it "renders the already challenged template" do
      get "/report-incorrect-partnership/already-challenged"
      expect(response).to render_template("challenge_partnerships/already_challenged")
    end
  end

  describe "POST /report-incorrect-partnership" do
    it "redirects to the success page" do
      when_i_submit_form_with_reason("mistake")

      expect(response).to redirect_to("/report-incorrect-partnership/success")
    end

    it "updates the partnership with the correct details" do
      freeze_time
      when_i_submit_form_with_reason("mistake")

      partnership_notification_email.partnerable.reload
      expect(partnership_notification_email.partnerable.challenge_reason).to eql "mistake"
      expect(partnership_notification_email.partnerable.challenged_at).to eql Time.zone.now
    end

    it "shows an error message when no option is selected" do
      when_i_submit_form_with_reason("")

      expect(response).to render_template("challenge_partnerships/show")
      expect(response.body).to include(CGI.escapeHTML("Error"))
    end
  end

  describe "GET /report-incorrect-partnership/success" do
    it "renders the success template" do
      get "/report-incorrect-partnership/success"
      expect(response).to render_template("challenge_partnerships/success")
    end
  end

private

  def when_i_submit_form_with_reason(reason)
    post "/report-incorrect-partnership", params: { challenge_partnership_form: {
      challenge_reason: reason,
      token: partnership_notification_email.token,
    } }
  end
end
