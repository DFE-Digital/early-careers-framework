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

        if params[:continue]
          @user = user_from_session
        else
          session.delete(:administrator_user)
          @user = User.new
        end

        authorize @user
      end

      def create
        authorize AdminProfile
        @user = User.new(permitted_attributes(User))

        if @user.invalid?
          render :new and return
        end

        session[:administrator_user] = @user
      end

      def success
        user = User.new(permitted_attributes(User))
        user.confirm

        authorize user, :create?
        authorize AdminProfile, :create?

        ActiveRecord::Base.transaction do
          user.save!
          AdminProfile.create!(user: user)
        end
        session.delete(:administrator_user)
      end

    private

      def user_from_session
        User.new(session[:administrator_user])
      end
    end
  end
end
