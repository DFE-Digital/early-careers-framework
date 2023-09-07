# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::ChangeLog", type: :request do
  let(:admin_user) { create(:user, :admin) }

  let!(:mentor_profile) { create(:mentor) }
  let!(:ect_profile) { create(:ect, mentor_profile_id: mentor_profile.id) }
  let!(:npq_profile) { create(:npq_participant_profile) }
  let!(:withdrawn_ect_profile_record) { create(:ect, :withdrawn_record) }
  let!(:mentor_with_no_ir) { create(:mentor).tap { |profile| profile.induction_records.destroy_all } }

  before do
    sign_in admin_user
  end

  describe "GET /admin/participants" do
    context "when participant is a mentor" do
      let(:route) { "/admin/participants/#{mentor_profile.id}/change_log" }

      it "renders without errors" do
        get route
        expect(response).to render_template "admin/participants/change_log/show"
      end
    end

    context "when participant is an ECT" do
      let(:route) { "/admin/participants/#{ect_profile.id}/change_log" }

      it "renders without errors" do
        get route
        expect(response).to render_template "admin/participants/change_log/show"
      end
    end

    context "when participant is an NPQ Trainee" do
      let(:route) { "/admin/participants/#{npq_profile.id}/change_log" }

      it "renders without errors" do
        get route
        expect(response).to render_template "admin/participants/change_log/show"
      end
    end

    context "when participant is a withdrawn ECT" do
      let(:route) { "/admin/participants/#{withdrawn_ect_profile_record.id}/change_log" }

      it "renders without errors" do
        get route
        expect(response).to render_template "admin/participants/change_log/show"
      end
    end

    context "when participant is missing their induction records" do
      let(:route) { "/admin/participants/#{mentor_with_no_ir.id}/change_log" }

      it "renders without errors" do
        get route
        expect(response).to render_template "admin/participants/change_log/show"
      end
    end
  end
end
