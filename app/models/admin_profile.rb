# frozen_string_literal: true

class AdminProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user

  def self.create_admin(full_name, email, sign_in_url)
    user = User.new(full_name:, email:)

    ActiveRecord::Base.transaction do
      user.save!
      AdminProfile.create!(user:)
      AdminMailer.with(admin: user, url: sign_in_url).account_created_email.deliver_now
    end
  end
end
