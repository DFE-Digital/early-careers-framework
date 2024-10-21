# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ admin dashboard routes" do
  let(:user) { create(:user, :admin) }
  let(:participant_profile) { create(:npq_participant_profile) }
  let(:npq_application) { create(:npq_application, :accepted) }

  before do
    sign_in user
  end

  describe "GET /admin/participants/:participant_id/npq_change_full_name/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/participants/#{participant_profile.id}/npq_change_full_name/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/participants/#{participant_profile.id}/npq_change_full_name/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PUT /admin/participants/:participant_id/npq_change_full_name" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          put("/admin/participants/#{participant_profile.id}/npq_change_full_name", params: {})
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        put("/admin/participants/#{participant_profile.id}/npq_change_full_name", params: { admin_participants_npq_change_full_name_form: { full_name: "test" } })

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET /admin/participants/:participant_id/npq_change_email/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/participants/#{participant_profile.id}/npq_change_email/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/participants/#{participant_profile.id}/npq_change_email/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PUT /admin/participants/:participant_id/npq_change_email" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          put("/admin/participants/#{participant_profile.id}/npq_change_email", params: {})
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        put("/admin/participants/#{participant_profile.id}/npq_change_email", params: { admin_participants_npq_change_email_form: { email: "test" } })

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/applications/:application_id/change_logs" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/applications/#{npq_application.id}/change_logs")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/applications/#{npq_application.id}/change_logs")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/analysis" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/analysis")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/analysis")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/change_name/:id/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/change_name/#{npq_application.id}/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/change_name/#{npq_application.id}/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PUT /admin/npq/applications/change_name/:id" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          put("/admin/npq/applications/change_name/#{npq_application.id}", params: {})
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        put("/admin/npq/applications/change_name/#{npq_application.id}", params: { user: { name: "test" } })

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET /admin/npq/applications/change_email/:id/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/change_email/#{npq_application.id}/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/change_email/#{npq_application.id}/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PUT /admin/npq/applications/change_email/:id" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          put("/admin/npq/applications/change_email/#{npq_application.id}", params: {})
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        put("/admin/npq/applications/change_email/#{npq_application.id}", params: { user: { email: "test" } })

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/edge_cases" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/edge_cases")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/edge_cases")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/eligible_for_funding/:id/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/eligible_for_funding/#{npq_application.id}/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/eligible_for_funding/#{npq_application.id}/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/eligibility_status/:id/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/eligibility_status/#{npq_application.id}/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/eligibility_status/#{npq_application.id}/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/npq/applications/notes/:id/edit" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/admin/npq/applications/notes/#{npq_application.id}/edit")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/admin/npq/applications/notes/#{npq_application.id}/edit")

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /lead-providers/guidance/npq-usage" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "does not exist" do
        expect {
          get("/lead-providers/guidance/npq-usage")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "exists" do
        get("/lead-providers/guidance/npq-usage")

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
