# frozen_string_literal: true

class AdminProfile < BaseProfile
  belongs_to :user

  def self.create_admin(full_name, email, sign_in_url)
    user = User.new(full_name: full_name, email: email)
    user.confirm

    ActiveRecord::Base.transaction do
      user.save!
      AdminProfile.create!(user: user)
      AdminMailer.account_created_email(user, sign_in_url).deliver_now
    end
  end
end
