# frozen_string_literal: true

module Admin
  module Administrators
    class ConfirmAdministratorController < Admin::BaseController
      skip_after_action :verify_policy_scoped

      def show
        authorize AdminProfile, :create?
        @user = User.new(full_name: params.require(:full_name), email: params.require(:email))
      end
    end
  end
end
