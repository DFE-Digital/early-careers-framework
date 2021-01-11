# frozen_string_literal: true

class Admin::LeadProviderUsersController < Admin::BaseController
  before_action :set_lead_provider
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, except: :index

  def index
    @users = policy_scope(@lead_provider.users)
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(permitted_attributes(User))
    authorize @user
    authorize LeadProviderProfile

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
    authorize @user
  end

  def update
    @user = @lead_provider.users.find(params[:id])
    authorize @user

    if @user.update(permitted_attributes(@user))
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
