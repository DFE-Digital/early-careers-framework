# frozen_string_literal: true

class AdminNominateInductionTutorForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :school_id

  def school
    School.find school_id
  end

  validates :full_name, presence: { message: "Enter a full name" }
  validates :email, presence: { message: "Enter email" }

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
