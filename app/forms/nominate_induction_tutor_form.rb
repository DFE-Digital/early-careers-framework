# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :token

  validates :full_name, presence: { message: "Enter a full name" }
  validates :email, presence: { message: "Enter email" }, format: { with: Devise.email_regexp, message: "Enter an email address in the correct format, like name@example.com" }

  def school
    NominationEmail.find_by(token: token).school
  end

  def save!
    raise UserExistsError if User.with_discarded.exists?(email: email)

    InductionCoordinatorProfile.create_induction_coordinator(
      full_name,
      email,
      school,
      Rails.application.routes.url_helpers.root_url(host: Rails.application.config.domain),
    )
  end
end

class UserExistsError < StandardError
end
