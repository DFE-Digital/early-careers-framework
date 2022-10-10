# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::NPQ::ChangeEmailController", :with_default_schedules do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create :user, full_name: "Roland Reilly" }
  let(:npq_profile) { create(:npq_participant_profile, user:) }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/npq_change_email/edit" do
    before { get("/admin/participants/#{npq_profile.id}/npq_change_email/edit") }

    specify "renders the edit form for a NPQ particiapnt's email address" do
      expect(response).to render_template("admin/participants/npq/change_email/edit")
      expect(response.body).to match(%r{<form.*action="/admin/participants/#{npq_profile.id}/npq_change_email"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change #{npq_profile.user.full_name}.* email address/)
    end

    it "has a form with a email field" do
      expect(response.body).to match(/<input.*"admin_participants_npq_change_email_form\[email\]/)
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end
  end

  describe "PUT /admin/participants/:participant_id/npq_change_email/" do
    let(:new_email) { "dave@somewhere.org" }
    let(:params) { { admin_participants_npq_change_email_form: { email: new_email } } }

    it "initializes an Admin::Participants::NPQ::ChangeEmailForm with the supplied email" do
      expect(Admin::Participants::NPQ::ChangeEmailForm).to receive(:new).with(npq_profile.user, email: new_email).and_call_original

      put("/admin/participants/#{npq_profile.id}/npq_change_email", params:)

      expect(npq_profile.user.reload.email).to eql(new_email)
      expect(response).to redirect_to(admin_participant_path(npq_profile))
    end

    context "when validation fails" do
      let(:new_email) { "@invalid" }

      it "re-renders the edit page" do
        put("/admin/participants/#{npq_profile.id}/npq_change_email", params:)

        expect(response).to render_template("admin/participants/npq/change_email/edit")
      end
    end
  end
end
