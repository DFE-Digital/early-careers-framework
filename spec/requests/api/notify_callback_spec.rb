# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nominations::NotifyCallbacks", type: :request do
  describe "POST /api/notify-callback" do
    context "when the email is a nomination email" do
      let(:nomination_email) { create(:nomination_email) }

      it "updates matching nomination email" do
        post "/api/notify-callback", params: {
          id: nomination_email.notify_id,
          status: "failed",
        }

        expect(nomination_email.reload.notify_status).to eq "failed"
      end

      context "when reference is nil" do
        it "returns successfully" do
          post "/api/notify-callback", params: {
            reference: nil,
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end

      context "when reference does not match any records" do
        it "returns successfully" do
          post "/api/notify-callback", params: {
            reference: "reference",
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when the email is a partnership notification email" do
      let(:partnership_notification_email) { create(:partnership_notification_email) }

      it "updates matching email" do
        post "/api/notify-callback", params: {
          id: partnership_notification_email.notify_id,
          status: "failed",
        }

        expect(partnership_notification_email.reload.notify_status).to eq "failed"
      end

      context "when id is nil" do
        it "returns successfully" do
          post "/api/notify-callback", params: {
            id: nil,
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end

      context "when id does not match any records" do
        it "returns successfully" do
          post "/api/notify-callback", params: {
            id: "reference",
            status: "delivered",
          }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
