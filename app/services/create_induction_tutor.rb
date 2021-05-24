# frozen_string_literal: true

class CreateInductionTutor < BaseService
  attr_accessor :school, :email, :full_name, :profile

  def initialize(school:, email:, full_name:)
    @school = school
    @email = email
    @full_name = full_name
  end

  def call
    ic_profile = nil

    ActiveRecord::Base.transaction do
      school.induction_coordinators.first.destroy! if school.induction_coordinators.first

      user = User.create!(full_name: full_name, email: email)
      ic_profile = InductionCoordinatorProfile.create!(user: user, schools: [school])
      SchoolMailer.nomination_confirmation_email(user: user, school: school, start_url: start_url).deliver_now
    end

    self.profile = ic_profile
  end

  def start_url
    @start_url ||= Rails.application.routes.url_helpers.root_url(host: Rails.application.config.domain)
  end
end
