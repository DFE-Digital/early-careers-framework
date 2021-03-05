# frozen_string_literal: true

module Admin
  module Administrators
    class AdministratorsController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index
      skip_after_action :verify_policy_scoped, except: :index

      def index
        @administrators = policy_scope(User).admins
      end

      def new
        authorize AdminProfile

        @user = User.new(new_user_params)
        authorize @user
      end

      def create
        authorize AdminProfile
        @user = User.new(create_user_params)

        if @user.invalid?
          render :new and return
        end

        redirect_to admin_administrators_confirm_administrator_path(full_name: @user.full_name, email: @user.email)
      end

    private

      def new_user_params
        { full_name: params[:full_name], email: params[:email] }
      end

      def create_user_params
        params.require(:user).permit(:full_name, :email)
      end
    end
  end
end
