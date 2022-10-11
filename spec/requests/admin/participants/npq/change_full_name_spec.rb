# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::NPQ::ChangeFullNameController", :with_default_schedules do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create :user, full_name: "Roland Reilly" }
  let(:npq_profile) { create(:npq_participant_profile, user:) }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/npq_change_full_name/edit" do
    before { get("/admin/participants/#{npq_profile.id}/npq_change_full_name/edit") }

    specify "renders the edit form for a NPQ particiapnt's full name" do
      expect(response).to render_template("admin/participants/npq/change_full_name/edit")
      expect(response.body).to match(%r{<form.*action="/admin/participants/#{npq_profile.id}/npq_change_full_name"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change #{npq_profile.user.full_name}.* name/)
    end

    it "has a form with a text field" do
      expect(response.body).to match(/<input.*"admin_participants_npq_change_full_name_form\[full_name\]/)
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end
  end

  describe "PUT /admin/participants/:participant_id/npq_change_full_name/" do
    let(:new_full_name) { "dave@somewhere.org" }
    let(:params) { { admin_participants_npq_change_full_name_form: { full_name: new_full_name } } }

    it "initializes an Admin::Participants::NPQ::ChangeFullNameForm with the supplied full name" do
      expect(Admin::Participants::NPQ::ChangeFullNameForm).to receive(:new).with(npq_profile.user, full_name: new_full_name).and_call_original

      put("/admin/participants/#{npq_profile.id}/npq_change_full_name", params:)

      expect(npq_profile.user.reload.full_name).to eql(new_full_name)
      expect(response).to redirect_to(admin_participant_path(npq_profile))
    end

    context "when validation fails" do
      let(:new_full_name) { "" }

      it "re-renders the edit page" do
        put("/admin/participants/#{npq_profile.id}/npq_change_full_name", params:)

        expect(response).to render_template("admin/participants/npq/change_full_name/edit")
      end
    end
  end
end
