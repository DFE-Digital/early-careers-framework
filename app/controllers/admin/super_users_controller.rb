# frozen_string_literal: true

module Admin
  class SuperUsersController < Admin::BaseController
    include Pundit::Authorization

    skip_after_action :verify_policy_scoped, only: %i[show]

    def show
      authorize :super_user, :show?
    end
  end
end
