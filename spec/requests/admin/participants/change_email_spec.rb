# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::ChangeEmailController" do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create :user, full_name: "Roland Reilly" }
  let(:npq_profile) { create(:npq_participant_profile, user:) }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/email/edit" do
    before { get("/admin/participants/#{npq_profile.id}/email/edit") }

    specify "renders the edit form for a particiapnt's email address" do
      expect(response).to render_template("admin/participants/change_email/edit")
      expect(response.body).to match(%r{<form.*action="/admin/participants/#{npq_profile.id}/email"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change mentor’s email address/)
    end

    it "has a form with a email field" do
      expect(response.body).to match(/<input.*"user\[email\]/)
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end

    context "when the user has a get an identity id" do
      let(:user) { create :user, get_an_identity_id: SecureRandom.uuid }

      it "redirects to the participants page" do
        expect(npq_profile.user.get_an_identity_id.present?).to be true
        expect(response).to redirect_to(admin_participants_path)
      end
    end
  end

  describe "PATCH (UPDATE) /admin/participants/:participant_id/email" do
    let(:new_email) { "random.rita@random.com" }
    let(:params) { { user: { "email" => new_email } } }
    let(:npq_profile_id) { npq_profile.id }

    it "changes the email for the user", :aggregate_failures do
      patch("/admin/participants/#{npq_profile.id}/email", params:)

      expect(response).to redirect_to admin_participants_path
      npq_profile.user.reload
      expect(npq_profile.user.email).to eq(new_email)
    end

    context "when the email fails to save" do
      let(:new_email) { "" }
      let(:old_email) { npq_profile.user.email }

      it "returns to the edit page", :aggregate_failures do
        patch("/admin/participants/#{npq_profile.id}/email", params:)

        expect(response).to render_template "admin/participants/change_email/edit"
        npq_profile.user.reload
        expect(npq_profile.user.email).to eq(old_email)
      end
    end
  end
end
