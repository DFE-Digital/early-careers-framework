# frozen_string_literal: true

module Admin::TestData
  class BaseController < Admin::BaseController
    skip_after_action :verify_authorized

    before_action :check_environment

  private

    def check_environment
      redirect_to root_path if Rails.env.production?
    end
  end
end
