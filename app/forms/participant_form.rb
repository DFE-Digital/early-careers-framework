# frozen_string_literal: true

class ParticipantForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :mentor_id

  validates :email, format: { with: Devise.email_regexp }
  validate :email_is_not_in_use

  def email_already_taken?
    if user_id
      User.where.not(id: user_id).exists?(email: email)
    else
      User.exists?(email: email)
    end
  end

private

  def email_is_not_in_use
    errors.add(:email, :taken) if email_already_taken?
  end
end
