# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe "#set_sentry_user" do
    context "when user not signed in" do
      it "sets sentry user to nil" do
        expect_any_instance_of(Sentry::Scope).not_to receive(:set_user)
        get :index
      end
    end

    context "when user signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "sets sentry user to user id" do
        expect_any_instance_of(Sentry::Scope).to receive(:set_user).with(id: user.id)
        get :index
      end
    end
  end
end
