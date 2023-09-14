# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization

  attr_accessor :email, :full_name, :school, :token

  # Validations
  validates :email, presence: true, notify_email: true, on: %i[email]
  validates :full_name, presence: true, on: %i[full_name email]
  validates :school, presence: true, on: %i[email]
  validate :not_current_sit, on: %i[email]
  validate :name_matches, on: %i[email]

  # Instance Methods
  def attributes
    { email:, full_name:, token: }
  end

  def save!
    raise errors.full_messages unless valid?(:email)

    ActiveRecord::Base.transaction do
      remove_current_sits
      ensure_user_persisted
      add_school_to_sit
      inform_user
    end

    true
  end

private

  def add_school_to_sit
    sit_profile.schools << school
  end

  def different_name?
    user.full_name != full_name
  end

  def ensure_user_persisted
    user.save! unless user.persisted?
  end

  def inform_user
    SchoolMailer.with(sit_profile:, school:, start_url:, step_by_step_url:)
                .nomination_confirmation_email.deliver_later
  end

  def name_matches
    if different_name?
      errors.add(:full_name, "A user with a different name (#{user.full_name}) has already been registered with this email address. Change the name or email address you entered.")
    end
  end

  def not_current_sit
    errors.add(:email, "The user with email #{user.email} is already an induction coordinator at #{school.name}") if sit_at_school?
  end

  def remove_current_sits
    school.induction_coordinators.each do |sit|
      next sit.induction_coordinator_profile.schools.delete(school) if sit.schools.count > 1
      next sit.induction_coordinator_profile.destroy! if sit.teacher_profile.present? || sit.npq_registered?

      sit.destroy!
    end
  end

  def sit_at_school?
    school.induction_coordinators.include?(user) if school
  end

  def sit_profile
    @sit_profile ||= user.induction_coordinator_profile || user.create_induction_coordinator_profile!
  end

  def start_url
    Rails.application.routes.url_helpers.root_url(
      host: Rails.application.config.domain.to_s,
      **UTMService.email(:new_induction_tutor),
    )
  end

  def step_by_step_url
    Rails.application.routes.url_helpers.step_by_step_url(
      host: Rails.application.config.domain.to_s,
      **UTMService.email(:new_induction_tutor),
    )
  end

  def user
    @user ||= Identity.find_user_by(email:) || User.new(email:, full_name:)
  end
end
