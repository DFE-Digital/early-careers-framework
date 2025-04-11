# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }

  let!(:mentor_profile)               { create(:mentor) }
  let!(:ect_profile)                  { create(:ect, mentor_profile_id: mentor_profile.id) }
  let!(:withdrawn_ect_profile_record) { create(:ect, :withdrawn_record) }
  let!(:induction_programme)          { create(:induction_programme, :fip) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/participants" do
    it "renders the index participants template" do
      get "/admin/participants"
      expect(response).to render_template "admin/participants/index"
    end

    it "includes all participants" do
      get "/admin/participants"

      aggregate_failures do
        expect(assigns(:participant_profiles)).to include ect_profile
        expect(assigns(:participant_profiles)).to include mentor_profile
        expect(assigns(:participant_profiles)).to include withdrawn_ect_profile_record
      end
    end

    it "can filter by type" do
      get "/admin/participants?type=ParticipantProfile::ECT"

      aggregate_failures do
        expect(assigns(:participant_profiles)).to include ect_profile
        expect(assigns(:participant_profiles)).to include withdrawn_ect_profile_record

        expect(assigns(:participant_profiles)).not_to include mentor_profile
      end
    end
  end

  context "when change of circumstances enabled" do
    describe "GET /admin/participants" do
      it "renders the index participants template" do
        get "/admin/participants"
        expect(response).to render_template "admin/participants/index"
      end

      it "includes all participants" do
        get "/admin/participants"
        expect(assigns(:participant_profiles)).to include ect_profile
        expect(assigns(:participant_profiles)).to include mentor_profile
        # NOTE: withdrawn in this way is not really relevent now
        expect(assigns(:participant_profiles)).to include withdrawn_ect_profile_record
      end

      it "can filter by type" do
        get "/admin/participants?type=ParticipantProfile::Mentor"
        expect(assigns(:participant_profiles)).not_to include ect_profile
        expect(assigns(:participant_profiles)).to include mentor_profile
        expect(assigns(:participant_profiles)).not_to include withdrawn_ect_profile_record
      end
    end
  end

  describe "GET /admin/participants/:id/school" do
    it "renders the show template" do
      get "/admin/participants/#{mentor_profile.id}/school"
      expect(response).to render_template("admin/participants/school/show")
    end

    it "shows the correct participant" do
      get "/admin/participants/#{ect_profile.id}/school"
      expect(response.body).to include(CGI.escapeHTML(ect_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(withdrawn_ect_profile_record.user.full_name))
    end

    context "when the participant has a withdrawn induction record" do
      before do
        ect_profile.current_induction_record.withdrawing!
      end

      it "shows the correct participant" do
        get "/admin/participants/#{ect_profile.id}/school"
        expect(response.body).to include(CGI.escapeHTML(ect_profile.user.full_name))
        expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
        expect(response.body).not_to include(CGI.escapeHTML(withdrawn_ect_profile_record.user.full_name))
        expect(response.body).to include("Withdrawn")
      end
    end
  end

  describe "GET /admin/participants/:participant_id/remove" do
    it "renders the remove participant template" do
      get "/admin/participants/#{ect_profile.id}/remove"
      expect(response).to render_template "admin/participants/remove"
    end
  end

  describe "DELETE /admin/participants/:id" do
    it "marks the participant record as withdrawn" do
      delete "/admin/participants/#{ect_profile.id}"
      expect(ect_profile.reload.withdrawn_record?).to be true
    end

    it "shows a success message" do
      delete "/admin/participants/#{ect_profile.id}"
      expect(response).to render_template "admin/participants/destroy_success"
    end

    it "updates analytics" do
      expect {
        delete "/admin/participants/#{ect_profile.id}"
      }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob).with(participant_profile_id: ect_profile.id)
    end
  end
end
