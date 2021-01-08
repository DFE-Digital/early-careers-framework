# frozen_string_literal: true

class AdminDashboardController < ApplicationController
  before_action :authenticate_user!

  def show; end
end
