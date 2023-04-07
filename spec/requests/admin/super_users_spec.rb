# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::SuperUsersController", type: :request do
  let(:user) { scenario.user }
  before { sign_in(user) }

  describe "GET /admin/schools" do
    context "when user is a super user" do
      let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build.with_super_user }

      it "allows access to the resource" do
        get("/admin/super-user")

        expect(response).to be_successful
      end
    end

    context "when user is a regular admin" do
      let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build }

      it "disallows access to the resource" do
        expect { get("/admin/super-user") }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
