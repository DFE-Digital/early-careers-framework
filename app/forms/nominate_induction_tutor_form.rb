# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :token, :school_id, :user_id

  validates :full_name, presence: true
  validates :email, presence: true, notify_email: true
  validate :email_is_not_in_use
  validate :name_matches

  def school
    if school_id
      School.find school_id
    else
      NominationEmail.find_by(token: token).school
    end
  end

  def email_already_taken?
    ParticipantProfile.active_record.ects.joins(:user).where(user: { email: email }).any?
  end

  def name_different?
    existing_name.present? && existing_name != full_name
  end

  def existing_name
    user_scope = user_id.present? ? User.induction_coordinators.where.not(id: user_id) : User.induction_coordinators
    existing_user = user_scope.find_by(email: email)
    return if existing_user.blank?

    existing_user.full_name
  end

private

  def email_is_not_in_use
    errors.add(:email, :taken) if email_already_taken?
  end

  def name_matches
    errors.add(:full_name, :does_not_match) if name_different?
  end
end
