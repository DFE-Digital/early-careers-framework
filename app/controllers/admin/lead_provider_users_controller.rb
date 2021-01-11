# frozen_string_literal: true

class Admin::LeadProviderUsersController < Admin::BaseController
  before_action :set_lead_provider

  def index
    @users = @lead_provider.users
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      @user.save!
      LeadProviderProfile.create!(user: @user, lead_provider: @lead_provider)
    end

    redirect_to admin_lead_provider_users_path
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def edit
    @user = @lead_provider.users.find(params[:id])
  end

  def update
    @user = @lead_provider.users.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_lead_provider_users_path
    else
      render :edit
    end
  end

private

  def set_lead_provider
    @lead_provider = LeadProvider.find(params[:lead_provider])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
