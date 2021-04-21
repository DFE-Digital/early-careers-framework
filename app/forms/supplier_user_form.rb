# frozen_string_literal: true

class SupplierUserForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :full_name, :email, :supplier
  validates :supplier, presence: { message: "Select one" }, on: :supplier
  validates :full_name, presence: { message: "Enter a name" }, on: :details
  validates :email,
            presence: { message: "Enter email" },
            format: { with: Devise.email_regexp, message: "Enter an email address in the correct format, like name@example.com" },
            on: :details
  validate :email_not_taken, on: :details

  def attributes
    { full_name: nil, email: nil, supplier: nil }
  end

  def chosen_supplier
    LeadProvider.find_by(id: supplier)
  end

  def save!
    profile = LeadProviderProfile.new(lead_provider: chosen_supplier)

    user = ActiveRecord::Base.transaction do
      user = User.create!(
        full_name: full_name,
        email: email,
      )
      profile.user = user
      profile.save!
      user
    end
    user
  end

private

  def email_not_taken
    errors.add(:email, :unique, message: "There is already a user with this email address") if User.find_by(email: email)
  end
end
