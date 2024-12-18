# frozen_string_literal: true

class CreateNewFakeSandboxDataJob < ApplicationJob
  EDT_NAME = "Education Development Trust"

  def perform(provider_name: EDT_NAME)
    return if Rails.env.production?

    @provider_name = provider_name

    if ecf_lead_provider.present? && random_school_cohort.present?
      10.times do
        name = ::Faker::Name.name
        ::EarlyCareerTeachers::Create.call(
          full_name: name,
          email: Faker::Internet.email(name:),
          school_cohort: random_school_cohort,
          mentor_profile_id: nil,
        )
      end
    end
  end

private

  def ecf_lead_provider
    @ecf_lead_provider ||= LeadProvider.find_by(name: @provider_name)
  end

  def random_school
    @random_school ||= ecf_lead_provider.schools.sample
  end

  def random_school_cohort
    @random_school_cohort ||= SchoolCohort.find_by(school: random_school, cohort: Cohort.current)
  end
end
