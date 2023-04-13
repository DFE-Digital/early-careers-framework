# frozen_string_literal: true

require "tasks/trn_generator"

class CreateNewFakeSandboxDataJob < ApplicationJob
  EDT_NAME = "Education Development Trust"

  def perform(provider_name: EDT_NAME)
    return if Rails.env.production?

    @provider_name = provider_name

    if ecf_lead_provider.present? && random_school_cohort.present?
      10.times do
        name = ::Faker::Name.name
        EarlyCareerTeachers::Create.call(
          full_name: name,
          email: Faker::Internet.email(name:),
          school_cohort: random_school_cohort,
          mentor_profile_id: nil,
        )
      end
    end

    if npq_lead_provider.present? && random_school.present?
      10.times do
        name = Faker::Name.name
        user = User.create!(full_name: name, email: Faker::Internet.email(name:))
        identity = Identity::Create.call(user:, origin: :npq)
        NPQApplication.create!(
          active_alert: "",
          date_of_birth: Date.new(1990, 1, 1),
          eligible_for_funding: true,
          funding_choice: "",
          headteacher_status: "",
          nino: "",
          school_urn: random_school.urn,
          teacher_reference_number: TRNGenerator.next,
          teacher_reference_number_verified: true,
          npq_course: NPQCourse.all.sample,
          npq_lead_provider:,
          participant_identity: identity,
          cohort: Cohort.active_registration_cohort,
        )
      end
    end
  end

private

  def ecf_lead_provider
    @ecf_lead_provider ||= LeadProvider.find_by(name: @provider_name)
  end

  def npq_lead_provider
    @npq_lead_provider ||= NPQLeadProvider.find_by(name: @provider_name)
  end

  def random_school
    @random_school ||= ecf_lead_provider.schools.sample
  end

  def random_school_cohort
    @random_school_cohort ||= SchoolCohort.find_by(school: random_school, cohort: Cohort.current)
  end
end
