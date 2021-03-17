# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Confirmations", type: :request do
  let(:confirmation_token) { "soC7rF8i_BgYdUxafFcP" }
  let(:school) { create(:school) }
  let(:induction_coordinator) { user.induction_coordinator_profile }

  let(:user) do
    create(:user, :induction_coordinator, confirmed_at: nil, confirmation_token: confirmation_token)
  end

  describe "GET /users/confirmation" do
    before do
      allow(UserMailer).to receive(:primary_contact_notification).and_call_original
      school.induction_coordinator_profiles << induction_coordinator
    end

    it "confirms the account" do
      get "/users/confirmation?confirmation_token=#{confirmation_token}"
      expect(user.reload.confirmed?).to be true
      expect(response).to render_template(:confirmed)
      expect(user.sign_in_count).to eq 1
    end

    it "notifies the school primary contact" do
      expect(UserMailer).to receive(:primary_contact_notification).with(user, school)

      get "/users/confirmation?confirmation_token=#{confirmation_token}"
    end

    context "when school primary contact email equals induction coordinator email" do
      before { user.update(email: school.primary_contact_email) }

      it "does not notify the school primary contact" do
        expect(UserMailer).not_to receive(:primary_contact_notification).with(user, school)

        get "/users/confirmation?confirmation_token=#{confirmation_token}"
      end
    end
  end

  describe "GET /users/confirmation" do
    context "when user is not an induction coordinator" do
      let!(:user) do
        create(:user, confirmed_at: nil, confirmation_token: confirmation_token)
      end

      it "does not notify the school primary contact" do
        expect(UserMailer).not_to receive(:primary_contact_notification).with(user, school)

        get "/users/confirmation?confirmation_token=#{confirmation_token}"
      end
    end
  end
end
