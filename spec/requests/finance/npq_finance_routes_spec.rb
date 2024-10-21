# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ finance dashboard routes" do
  let(:user) { create(:user, :finance) }
  let(:participant_profile) { create(:npq_participant_profile) }
  let(:npq_application) { create(:npq_application, :accepted) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:cohort) { create(:cohort, :current) }
  let(:npq_statement) { create(:npq_statement, cpd_lead_provider:, cohort:) }
  let(:npq_course) { create(:npq_course) }

  before do
    sign_in user
  end

  describe "GET /finance/participant_profiles/:id/npq/change_training_status/new" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/participant_profiles/#{participant_profile.id}/npq/change_training_status/new")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/participant_profiles/#{participant_profile.id}/npq/change_training_status/new")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /finance/participant_profiles/:id/npq/change_lead_provider/new" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/participant_profiles/#{participant_profile.id}/npq/change_lead_provider/new")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/participant_profiles/#{participant_profile.id}/npq/change_lead_provider/new")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /finance/npq_applications/:id/change_lead_provider_approval_status/new" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/npq_applications/#{npq_application.id}/change_lead_provider_approval_status/new")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/npq_applications/#{npq_application.id}/change_lead_provider_approval_status/new")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /finance/payment-breakdowns/choose-provider-npq" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/payment-breakdowns/choose-provider-npq")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/payment-breakdowns/choose-provider-npq")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /finance/payment-breakdowns/choose-provider-npq" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          post("/finance/payment-breakdowns/choose-provider-npq")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        post("/finance/payment-breakdowns/choose-provider-npq")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /finance/payment-breakdowns/choose-npq-statement" do
    let(:params) do
      {
        npq_lead_provider: npq_lead_provider.id,
        statement: npq_statement.name,
        cohort_year: cohort.start_year,
      }
    end

    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          post("/finance/payment-breakdowns/choose-npq-statement", params:)
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        post("/finance/payment-breakdowns/choose-npq-statement", params:)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "GET /finance/npq/statements/:statement_id/assurance-report" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/npq/statements/#{npq_statement.id}/assurance-report.csv")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/npq/statements/#{npq_statement.id}/assurance-report.csv")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /finance/npq/payment-overviews/:lead_provider_id/statements/:statement_id/courses/:id" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{npq_statement.id}/courses/#{npq_course.id}")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end
  end

  describe "GET /finance/npq/payment-overviews/:lead_provider_id/statements/:statement_id/voided" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{npq_statement.id}/voided")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{npq_statement.id}/voided")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /finance/npq/payment-overviews/:lead_provider_id/statements/:id" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{npq_statement.id}")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        get("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{npq_statement.id}")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /finance/npq/participant_outcomes/:participant_outcome_id/resend" do
    context "when :disable_npq feature is active" do
      before { FeatureFlag.activate(:disable_npq) }

      it "route should not exist" do
        expect {
          get("/finance/npq/participant_outcomes/made-up/resend")
        }.to raise_error(ActionController::RoutingError, /No route matches/)
      end
    end

    context "when :disable_npq feature is not active" do
      before { FeatureFlag.deactivate(:disable_npq) }

      it "route should exist" do
        expect {
          get("/finance/npq/participant_outcomes/made-up/resend")
        }.to raise_error(ActiveRecord::RecordNotFound, /made-up/)
      end
    end
  end
end
