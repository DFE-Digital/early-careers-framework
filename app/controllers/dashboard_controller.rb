# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    if @current_user.lead_provider?
      @lead_provider = @current_user.lead_provider
    end
  end
end
