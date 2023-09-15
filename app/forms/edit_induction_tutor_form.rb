# frozen_string_literal: true

class EditInductionTutorForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization

  attr_accessor :email, :full_name, :induction_tutor

  # Validations
  validates :email, presence: true, notify_email: true
  validates :full_name, presence: true
  validates :induction_tutor, presence: true
  validate :name_is_changeable
  validate :email_not_in_use

  # Instance Methods
  def attributes
    { email:, full_name: }
  end

  def save
    valid? && induction_tutor.update!(full_name:, email:)
  end

  alias_method :call, :save

private

  def name_matches?
    NameMatcher.new(full_name, induction_tutor.full_name).matches? if full_name
  end

  def email_not_in_use
    return true if email_user.blank?
    return true if email_user == induction_tutor

    errors.add(:email, "not valid. A different user was registered with this email address.")
  end

  def email_user
    @email_user ||= Identity.find_user_by(email:)
  end

  def name_is_changeable
    errors.add(:full_name, "not valid. It looks like a different person's name") unless name_matches?
  end
end
