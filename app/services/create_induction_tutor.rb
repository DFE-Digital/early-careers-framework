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
      remove_existing_induction_coordinator

      if (user = User.find_by(email: email))&.induction_coordinator?
        raise if user.full_name != full_name

        user.induction_coordinator_profile.schools << school
      else
        user = User.create!(full_name: full_name, email: email)
        InductionCoordinatorProfile.create!(user: user, schools: [school])
      end

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

private

  def remove_existing_induction_coordinator
    existing_induction_coordinator = school.induction_coordinators.first
    return if existing_induction_coordinator.nil?

    if existing_induction_coordinator.induction_coordinator_profile.schools.count > 1
      existing_induction_coordinator.induction_coordinator_profile.schools.delete(school)
    elsif existing_induction_coordinator.mentor?
      existing_induction_coordinator.induction_coordinator_profile.destroy!
    else
      existing_induction_coordinator.destroy!
    end
  end
end
