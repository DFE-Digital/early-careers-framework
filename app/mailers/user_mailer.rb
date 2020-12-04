class UserMailer < ApplicationMailer
  default from: "from@example.com"

  def sign_in_email(user, url)
    @user = user
    @url  = url
    mail to: @user.email, subject: "Sign in into ECF"
  end
end
