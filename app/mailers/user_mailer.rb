class UserMailer < ApplicationMailer
  def validate_email(user, url)
    @user = user
    @url  = url
    mail to: @user.email, subject: "Sign in into ECF"
  end
end