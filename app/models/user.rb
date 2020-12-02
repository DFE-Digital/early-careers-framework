require 'byebug'

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :passwordless_authenticatable

  def password_required?
    false
  end
end
