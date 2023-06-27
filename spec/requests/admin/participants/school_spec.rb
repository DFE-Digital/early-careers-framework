# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::School", type: :request do
  let(:admin_user) { create(:user, :admin) }

  let!(:mentor_profile)               { create(:mentor) }
  let!(:ect_profile)                  { create(:ect, mentor_profile_id: mentor_profile.id) }
  let!(:npq_profile)                  { create(:npq_participant_profile) }
  let!(:withdrawn_ect_profile_record) { create(:ect, :withdrawn_record) }
  let!(:induction_programme)          { create(:induction_programme, :fip) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/participants" do
    let(:route) { "/admin/participants/#{mentor_profile.id}/school" }

    it "renders without errors" do
      get route
      expect(response).to render_template "admin/participants/school/show"
    end

    context "when participant is missing their induction records" do
      before do
        mentor_profile.induction_records.destroy_all
      end

      it "renders without errors" do
        get route
        expect(response).to render_template "admin/participants/school/show"
      end
    end
  end
end
