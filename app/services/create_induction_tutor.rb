# frozen_string_literal: true

class CreateInductionTutor < BaseService
  attr_accessor :school, :email, :full_name

  def initialize(school:, email:, full_name:)
    @school = school
    @email = email
    @full_name = full_name
  end

  def call
    ActiveRecord::Base.transaction do
      school.induction_coordinators.first.destroy! if school.induction_coordinators.first

      user = User.create!(full_name: full_name, email: email)
      InductionCoordinatorProfile.create!(user: user, schools: [school])

      # TODO: This should really be using deliver_later, but this can't be tested via Cypress
      # After discussion leaving this as deliver_now with  this comment
      SchoolMailer.nomination_confirmation_email(user: user, school: school, start_url: start_url).deliver_now
    end
  end

  def start_url
    Rails.application.routes.url_helpers.root_url(
      host: Rails.application.config.domain,
      **UTMService.email(:new_induction_tutor),
    )
  end
end
