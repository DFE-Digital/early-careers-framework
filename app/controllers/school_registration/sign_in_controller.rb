class SchoolRegistration::SignInController < ApplicationController
  def index
    @user = User.new
  end
end
