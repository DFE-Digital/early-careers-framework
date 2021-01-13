# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def show; end
end
