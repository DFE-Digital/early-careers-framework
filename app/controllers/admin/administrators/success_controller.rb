# frozen_string_literal: true

module Admin
  module Administrators
    class SuccessController < Admin::BaseController
      skip_after_action :verify_policy_scoped

      def create
        user = User.new(permitted_attributes(User))
        user.confirm

        authorize user
        authorize AdminProfile

        ActiveRecord::Base.transaction do
          user.save!
          AdminProfile.create!(user: user)
        end
        session.delete(:administrator_user)
      end
    end
  end
end
