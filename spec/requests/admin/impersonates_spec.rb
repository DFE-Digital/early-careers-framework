# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:other_admin_user) { create(:user, :admin) }
  let!(:cohort) { create(:cohort, :current) }
  let!(:induction_coordinator) { create(:user, :induction_coordinator) }

  before do
    sign_in admin_user
  end

  describe "POST /admin/impersonate" do
    it "sets impersonation session" do
      when_i_impersonate(induction_coordinator)
      expect(cookies[:impersonation_start_path]).to eql(admin_school_path(induction_coordinator.school))
      expect(session[:impersonated_user_id]).to eql(induction_coordinator.id.to_s)
    end

    it "redirects to impersonated user start page" do
      when_i_impersonate(induction_coordinator)
      follow_redirect!
      expect(response).to redirect_to(schools_cohort_setup_start_path(induction_coordinator.school, cohort.start_year))
    end

    it "errors if you impersonate yourself" do
      when_i_impersonate(admin_user)
      expect(response).to redirect_to(admin_school_path(induction_coordinator.school))
      expect(flash[:warning]).to eql("You cannot impersonate yourself")
    end

    it "errors if you impersonate an admin" do
      when_i_impersonate(other_admin_user)
      expect(response).to redirect_to(admin_school_path(induction_coordinator.school))
      expect(flash[:warning]).to eql("You cannot impersonate another admin user")
    end
  end

  describe "DELETE /admin/impersonate" do
    before do
      when_i_impersonate(induction_coordinator)
    end

    it "clears impersonation session" do
      when_i_stop_impersonating(induction_coordinator)
      expect(cookies[:impersonation_start_path]).to be_blank
      expect(session[:impersonated_user_id]).to be_blank
    end

    it "redirects to impersonation starting point" do
      when_i_stop_impersonating(induction_coordinator)
      expect(response).to redirect_to(admin_school_path(induction_coordinator.school))
    end
  end

private

  def when_i_impersonate(user)
    post "/admin/impersonate",
         params: { impersonated_user_id: user&.id },
         headers: { "HTTP_REFERER" => admin_school_path(induction_coordinator.school) }
  end

  def when_i_stop_impersonating(user)
    delete "/admin/impersonate", params: {
      impersonated_user_id: user&.id,
    }
  end
end
