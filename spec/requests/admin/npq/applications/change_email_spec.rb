# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::ChangeEmailController" do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create :user, email: "roland.reilly@sensible.com" }
  let(:application) { create(:npq_application, user:) }

  before { sign_in(admin_user) }

  describe "GET /admin/npq/applications/change_email/:id/edit" do
    before { get("/admin/npq/applications/change_email/#{application.id}/edit") }

    it "renders the edit form for a NPQ applicants's full name" do
      expect(response).to render_template("admin/npq/applications/change_email/edit")
      expect(response.body).to match(%r{<form.*action="/admin/npq/applications/change_email/#{application.id}"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change applicant's email/)
    end

    it "has a form with a text field" do
      expect(response.body).to match(/<input.*name="user\[email\]/)
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end

    context "when the user has a get an identity id" do
      let(:user) { create :user, get_an_identity_id: SecureRandom.uuid }

      it "redirects to the applications page" do
        expect(application.user.get_an_identity_id.present?).to be true
        expect(response).to redirect_to(admin_npq_applications_application_path)
      end
    end
  end

  describe "PATCH (UPDATE) /admin/npq/applications/change_email/:id" do
    let(:new_email) { "random.rita@random.com" }
    let(:params) { { user: { "email" => new_email } } }
    let(:application_id) { application.id }

    it "changes the email for the user", :aggregate_failures do
      patch("/admin/npq/applications/change_email/#{application.id}", params:)

      expect(response).to redirect_to "/admin/npq/applications/applications/#{application_id}"
      application.user.reload
      expect(application.user.email).to eq(new_email)
    end

    context "when the email fails to save" do
      let(:new_email) { "" }
      let(:old_email) { application.user.email }

      it "returns to the edit page", :aggregate_failures do
        patch("/admin/npq/applications/change_email/#{application.id}", params:)

        expect(response).to render_template "admin/npq/applications/change_email/edit"
        application.user.reload
        expect(application.user.email).to eq(old_email)
      end
    end
  end
end
