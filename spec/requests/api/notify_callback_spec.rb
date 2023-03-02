# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nominations::NotifyCallbacks", type: :request do
  let(:token) { "T0K3N" }

  let(:headers) do
    encoded_credentials =
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    { "Authorization" => encoded_credentials }
  end

  before do
    allow(Rails.application.credentials).to receive(:notify_callback_token).and_return(token)
  end

  describe "POST /api/notify-callback" do
    context "when the email is a nomination email" do
      let(:sent_at) { 1.hour.ago.to_s }
      let(:nomination_email) { create(:nomination_email) }

      it "creates a handle notify callback job" do
        expect {
          post "/api/notify-callback", headers:, params: {
            id: nomination_email.notify_id,
            status: "failed",
            sent_at:,
            template_id: "123",
          }
        }.to have_enqueued_job(HandleNotifyCallbackJob).with(email_id: nomination_email.notify_id, delivery_status: "failed", sent_at:, template_id: "123")
      end

      context "when reference is nil" do
        it "returns successfully" do
          post "/api/notify-callback", headers:, params: {
            reference: nil,
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end

      context "when reference does not match any records" do
        it "returns successfully" do
          post "/api/notify-callback", headers:, params: {
            reference: "reference",
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when the email is a partnership notification email" do
      let(:partnership_notification_email) { create(:partnership_notification_email) }

      context "when id is nil" do
        it "returns successfully" do
          post "/api/notify-callback", headers:, params: {
            id: nil,
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end

      context "when id does not match any records" do
        it "returns successfully" do
          post "/api/notify-callback", headers:, params: {
            id: "reference",
            status: "delivered",
          }

          expect(response).to have_http_status(:no_content)
        end
      end
    end

    context "when a bearer token is not provided" do
      it "returns 401" do
        post "/api/notify-callback"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a bearer token is not provided" do
      it "returns 401" do
        encoded_credentials =
          ActionController::HttpAuthentication::Token.encode_credentials("I am wrong")
        incorrect_token_headers = { "Authorization" => encoded_credentials }

        post "/api/notify-callback", headers: incorrect_token_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when there isn't a notify callback token in the credentials" do
      let(:token) { nil }

      it "doesn't require authentication" do
        post "/api/notify-callback"

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
