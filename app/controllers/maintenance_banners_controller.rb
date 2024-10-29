# frozen_string_literal: true

class MaintenanceBannersController < ApplicationController
  def dismiss
    cookies[:dismiss_maintenance_banner_until] = 1.week.from_now

    redirect_back(fallback_location: root_path)
  end
end
