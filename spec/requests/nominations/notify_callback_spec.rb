# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nominations::NotifyCallbacks", type: :request do
  describe "POST /nominations/notify-callback" do
    let(:nomination_email) { create(:nomination_email) }

    it "updates matching nomination email" do
      post "/nominations/notify-callback", params: {
        reference: nomination_email.token,
        status: "failed",
      }

      expect(nomination_email.reload.notify_status).to eq "failed"
    end

    context "when reference is nil" do
      it "returns successfully" do
        post "/nominations/notify-callback", params: {
          reference: nil,
          status: "delivered",
        }

        expect(response).to have_http_status(:success)
      end
    end

    context "when reference does not match any records" do
      it "returns successfully" do
        post "/nominations/notify-callback", params: {
          reference: "reference",
          status: "delivered",
        }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
