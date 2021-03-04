# frozen_string_literal: true

module Admin
  module Administrators
    class AdministratorsController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index

      def index
        @administrators = policy_scope(AdminProfile)&.map(&:user) # TODO: make more efficient
      end
    end
  end
end
