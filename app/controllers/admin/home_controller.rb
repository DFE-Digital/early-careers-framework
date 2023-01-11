# frozen_string_literal: true

module Admin
  class HomeController < Admin::BaseController
    skip_after_action :verify_authorized, only: :show
    skip_after_action :verify_policy_scoped, only: :show

    # this isn't used yet
    def show; end
  end
end
