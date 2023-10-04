# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe "logging ip addresses" do
    before { allow(Rails.logger).to receive(:info) }

    it "logs the x-real-ip header and remote_ip" do
      request.headers.merge!("REMOTE_ADDR" => "1.2.3.4")
      request.headers.merge!({ "X-Real-IP" => "9.8.7.6" })
      get :index

      expect(Rails.logger).to have_received(:info).with("x-real-ip: 9.***.***.6 (remote ip: 1.***.***.4)")
    end

    context "when there is no x-real-ip header or remote_ip" do
      it "logs out successfully" do
        request.headers.merge!("REMOTE_ADDR" => "")
        get :index

        expect(Rails.logger).to have_received(:info).with("x-real-ip:  (remote ip: )")
      end
    end

    context "when there is an IP address in an unexpected format" do
      it "logs out successfully" do
        request.headers.merge!("REMOTE_ADDR" => "2001:0db8:85a3:0000:0000:8a2e:0370:7334")
        request.headers.merge!({ "X-Real-IP" => "9.8.7.6/25" })
        get :index

        expect(Rails.logger).to have_received(:info).with("x-real-ip: 9.***.***.6/25 (remote ip: )")
      end
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
