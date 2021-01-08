# frozen_string_literal: true

class Admin::LeadProviderUsersController < ApplicationController
  before_action :set_lead_provider

  def index
    @users = User.joins(:lead_provider_profile).where(lead_provider_profiles: { lead_provider: @lead_provider })
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(
      first_name: params.dig(:user, :first_name),
      last_name: params.dig(:user, :last_name),
      email: params.dig(:user, :email),
    )

    ActiveRecord::Base.transaction do
      @user.save!
      LeadProviderProfile.create!(user: @user, lead_provider: @lead_provider)
    end

    redirect_to admin_lead_provider_users_path
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(params.require(:user).permit(%i[first_name last_name email]))
      redirect_to admin_lead_provider_users_path
    else
      render :edit
    end
  end

private

  def set_lead_provider
    @lead_provider = LeadProvider.find(params[:lead_provider])
  end
end
