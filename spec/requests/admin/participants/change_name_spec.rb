# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::participants::ChangeNameController", :with_default_schedules do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create :user, full_name: "Roland Reilly" }
  let(:npq_profile) { create(:npq_participant_profile, user:) }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/name/edit" do
    before { get("/admin/participants/#{npq_profile.id}/name/edit") }

    it "renders the edit form for a NPQ applicants's full name", :aggregate_failures do
      expect(response).to render_template("admin/participants/change_name/edit")
      expect(response.body).to match(%r{<form.*action="/admin/participants/#{npq_profile.id}/name"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change mentor’s name/)
    end

    it "has a form with a text field" do
      expect(response.body).to match(/<input.*name="user\[full_name\]/)
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end
  end

  describe "PATCH (UPDATE) /admin/participants/change_name/:id" do
    let(:new_full_name) { "Random Rita" }
    let(:params) { { user: { "full_name" => new_full_name } } }
    let(:npq_profile_id) { npq_profile.id }

    it "changes the name for the user", :aggregate_failures do
      patch("/admin/participants/#{npq_profile_id}/name", params:)

      expect(response).to redirect_to admin_participants_path
      npq_profile.user.reload
      expect(npq_profile.user.full_name).to eq(new_full_name)
    end

    context "when the name fails to save" do
      let(:new_full_name) { "" }
      let(:old_full_name) { npq_profile.user.full_name }

      it "returns to the edit page", :aggregate_failures do
        patch("/admin/participants/#{npq_profile.id}/name", params:)

        expect(response).to render_template "admin/participants/change_name/edit"
        npq_profile.user.reload
        expect(npq_profile.user.full_name).to eq(old_full_name)
      end
    end
  end
end
