# frozen_string_literal: true

module Admin
  module Administrators
    class SuccessController < Admin::BaseController
      skip_after_action :verify_policy_scoped

      def create
        user = User.new(create_user_params)
        user.confirm

        authorize user
        authorize AdminProfile

        ActiveRecord::Base.transaction do
          user.save!
          AdminProfile.create!(user: user)
        end
      end

    private

      def create_user_params
        params.require(:user).permit(:full_name, :email)
      end
    end
  end
end
