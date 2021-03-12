# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Partnerships", type: :request do
  let(:partnership) { create(:partnership) }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/partnerships/:id" do
    it "renders the show template" do
      get "/admin/partnerships/#{partnership.id}"
      expect(response).to render_template("admin/partnerships/show")
      expect(response.body).to include(CGI.escapeHTML("Partnership information"))
      expect(response.body).to include(CGI.escapeHTML("Reject partnership"))
    end

    context "when partnership has been rejected" do
      before do
        partnership.update(
          status: "rejected",
          rejected_at: Time.zone.now,
          reason_for_rejection: "Other",
        )
      end

      it "shows the reason for the rejection" do
        get "/admin/partnerships/#{partnership.id}"
        expect(response.body).to include(CGI.escapeHTML("Rejected at"))
        expect(response.body).to include(CGI.escapeHTML("other"))
      end
    end
  end

  describe "PATCH /admin/partnerships/:id" do
    it "updates the status and redirects to the show page" do
      patch "/admin/partnerships/#{partnership.id}/reject", params: {
        partnership: { reason_for_rejection: "other" },
      }

      expect(partnership.reload.rejected?).to be true
      expect(partnership.rejected_with_other?).to be true
      expect(response).to redirect_to(:admin_partnership)
      expect(flash[:notice]).to eq "Partnership successfully rejected"
    end
  end
end
