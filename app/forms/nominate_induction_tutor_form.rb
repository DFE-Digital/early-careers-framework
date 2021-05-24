# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :token, :school_id, :user_id

  validates :full_name, presence: true
  validates :email, presence: true, format: { with: Devise.email_regexp }
  validate :email_is_not_in_use

  def school
    if school_id
      School.find school_id
    else
      NominationEmail.find_by(token: token).school
    end
  end

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
