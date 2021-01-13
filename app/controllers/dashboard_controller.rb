# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to admin_dashboard_path if current_user.admin_profile
  end
end
