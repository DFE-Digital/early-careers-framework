# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::ChangeNameController" do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create :user, full_name: "Roland Reilly" }
  let(:application) { create(:npq_application, user:) }

  before { sign_in(admin_user) }

  describe "GET /admin/npq/applications/change_name/:id/edit" do
    before { get("/admin/npq/applications/change_name/#{application.id}/edit") }

    it "renders the edit form for a NPQ applicants's full name" do
      expect(response).to render_template("admin/npq/applications/change_name/edit")
      expect(response.body).to match(%r{<form.*action="/admin/npq/applications/change_name/#{application.id}"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change applicant's name/)
    end

    it "has a form with a text field" do
      expect(response.body).to match(/<input.*name="user\[full_name\]/)
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

  describe "PATCH (UPDATE) /admin/npq/applications/change_name/:id" do
    let(:new_full_name) { "Random Rita" }
    let(:params) { { user: { "full_name" => new_full_name } } }
    let(:application_id) { application.id }

    it "changes the name for the user", :aggregate_failures do
      patch("/admin/npq/applications/change_name/#{application.id}", params:)

      expect(response).to redirect_to "/admin/npq/applications/applications/#{application_id}"
      application.user.reload
      expect(application.user.full_name).to eq(new_full_name)
    end

    context "when the name fails to save" do
      let(:new_full_name) { "" }
      let(:old_full_name) { application.user.full_name }

      it "returns to the edit page", :aggregate_failures do
        patch("/admin/npq/applications/change_name/#{application.id}", params:)

        expect(response).to render_template "admin/npq/applications/change_name/edit"
        application.user.reload
        expect(application.user.full_name).to eq(old_full_name)
      end
    end
  end
end
