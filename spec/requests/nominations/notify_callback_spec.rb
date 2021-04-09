# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nominations::NotifyCallbacks", type: :request do
  describe "POST /nominations/notify-callback" do
    let(:nomination_email) { create(:nomination_email) }

    it "updates matching nomination email" do
      post "/nominations/notify-callback", params: {
        reference: nomination_email.token,
        status: "failure",
      }

      expect(nomination_email.reload.notify_status).to eq "failure"
    end
  end
end
