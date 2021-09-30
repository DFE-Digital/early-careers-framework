# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:other_admin_user) { create(:user, :admin) }
  let(:cohort) { create(:cohort) }
  let!(:user) { create(:user, :induction_coordinator) }

  before do
    sign_in admin_user
  end

  describe "POST /admin/impersonate" do
    it "sets impersonation session" do
      when_i_impersonate(user)
      expect(session[:impersonated_user_id]).to eql(user.id.to_s)
    end

    it "redirects to impersonated user start page" do
      when_i_impersonate(user)
      expect(response).to redirect_to(schools_choose_programme_path(user.school))
    end

    it "errors if you impersonate yourself" do
      when_i_impersonate(admin_user)
      expect(response).to redirect_to "/admin/schools"
      expect(flash[:warning]).to eql("You cannot impersonate yourself")
    end

    it "errors if you impersonate an admin" do
      when_i_impersonate(other_admin_user)
      expect(response).to redirect_to "/admin/schools"
      expect(flash[:warning]).to eql("You cannot impersonate another admin user")
    end
  end

  describe "DELETE /admin/impersonate" do
    before do
      when_i_impersonate(user)
    end

    it "clears impersonation session" do
      when_i_stop_impersonating(user)
      expect(session[:impersonated_user_id]).to be_blank
    end

    it "redirects to support user start page" do
      when_i_stop_impersonating(user)
      expect(response).to redirect_to("/admin/schools")
    end
  end

private

  def when_i_impersonate(user)
    post "/admin/impersonate", params: {
      impersonated_user_id: user&.id,
    }
  end

  def when_i_stop_impersonating(user)
    delete "/admin/impersonate", params: {
      impersonated_user_id: user&.id,
    }
  end
end
