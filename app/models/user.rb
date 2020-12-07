class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :rememberable, :validatable, :confirmable, :passwordless_authenticatable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  def password_required?
    false
  end
end
