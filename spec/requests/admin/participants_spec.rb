# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:cohort) { create(:cohort) }
  let(:school) { create(:school) }

  let(:school_cohort) { create(:school_cohort, school: school, cohort: cohort) }
  let!(:mentor_profile) { create :participant_profile, :mentor, school_cohort: school_cohort }
  let!(:ect_profile) { create :participant_profile, :ect, school_cohort: school_cohort, mentor_profile: mentor_profile }
  let!(:npq_profile) { create(:participant_profile, :npq, school: school) }
  let!(:withdrawn_ect_profile) { create(:participant_profile, :ect, status: "withdrawn", school_cohort: school_cohort) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/participants" do
    it "renders the index participants template" do
      get "/admin/participants"
      expect(response).to render_template "admin/participants/index"
    end

    it "only includes active participants" do
      get "/admin/participants"
      expect(assigns(:participant_profiles)).to include ect_profile
      expect(assigns(:participant_profiles)).to include mentor_profile
      expect(assigns(:participant_profiles)).to include npq_profile
      expect(assigns(:participant_profiles)).not_to include withdrawn_ect_profile
    end
  end

  describe "GET /admin/participants/:id" do
    it "renders the show template" do
      get "/admin/participants/#{mentor_profile.id}"
      expect(response).to render_template("admin/participants/show")
    end

    it "shows the correct participant" do
      get "/admin/participants/#{ect_profile.id}"
      expect(response.body).to include(CGI.escapeHTML(ect_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(npq_profile.user.full_name))
    end
  end

  describe "GET /admin/participants/:participant_id/remove" do
    it "renders the remove participant template" do
      get "/admin/participants/#{ect_profile.id}/remove"
      expect(response).to render_template "admin/participants/remove"
    end
    it "does not allow NPQ participants" do
      expect { get "/admin/participants/#{npq_profile.id}/remove" }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "DELETE /admin/participants/:id" do
    it "marks the participant as withdrawn" do
      delete "/admin/participants/#{ect_profile.id}"
      expect(ect_profile.reload.withdrawn_record?).to be true
    end

    it "does not withdraw NPQ participants" do
      expect { delete "/admin/participants/#{npq_profile.id}" }.to raise_error Pundit::NotAuthorizedError
      expect(npq_profile.active_record?).to be true
    end

    it "shows a success message" do
      delete "/admin/participants/#{ect_profile.id}"
      expect(response).to render_template "admin/participants/destroy_success"
    end
  end
end
