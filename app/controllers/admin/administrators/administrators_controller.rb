# frozen_string_literal: true

module Admin
  module Administrators
    class AdministratorsController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index
      skip_after_action :verify_policy_scoped, except: :index

      def index
        @administrators = policy_scope(AdminProfile)&.map(&:user) # TODO: make more efficient
      end

      def new
        authorize AdminProfile

        @user = User.new
        authorize @user
      end
    end
  end
end
