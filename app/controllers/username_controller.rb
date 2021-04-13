# frozen_string_literal: true

class UsernameController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def create
    current_user.update!(user_params.merge(account_created: true))
    redirect_to dashboard_path
  end

  def edit; end

  def update
    current_user.update!(user_params)
    redirect_to dashboard_path
  end

private

  def user_params
    params.require(:user).permit(:username)
  end
end
