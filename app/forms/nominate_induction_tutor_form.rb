# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization

  attr_accessor :full_name, :email, :token, :school_id, :user_id

  validates :full_name, presence: true, on: :full_name
  validates :email, presence: true, notify_email: true, on: :email
  validate :different_name, on: :full_name
  validate :email_is_not_in_use, on: :email
  validate :name_matches, on: :email

  def attributes
    {
      full_name:,
      email:,
      token:,
    }
  end

  def school
    if school_id
      School.find school_id
    else
      NominationEmail.find_by(token:).school
    end
  end

  def existing_name
    user_scope = user_id.present? ? User.induction_coordinators.where.not(id: user_id) : User.induction_coordinators
    existing_user = user_scope.find_by(email:)
    return if existing_user.blank?

    existing_user.full_name
  end

private

  def email_is_not_in_use
    if email_already_taken?
      other_school = school_using_this_email(email)
      if other_school.present?
        errors.add(:email, "The email address #{email} is already used by a user at #{other_school.name}")
      else
        errors.add(:email, "The email address #{email} is already in use")
      end
    end
  end

  def email_already_taken?
    ParticipantProfile.active_record.ects.joins(:user).where(user: { email: }).any?
  end

  def different_name
    if name_different?
      errors.add(:full_name, "An induction tutor has already been nominated using this email address, with the name #{existing_name}. The name you entered is #{full_name}.")
    end
  end

  def name_matches
    errors.add(:full_name, :does_not_match) if name_different?
  end

  def name_different?
    existing_name.present? && existing_name != full_name
  end

  def school_using_this_email(email)
    Identity.find_user_by(email:).schools.first
  end

end
