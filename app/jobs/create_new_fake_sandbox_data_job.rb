# frozen_string_literal: true

require "tasks/trn_generator"

class CreateNewFakeSandboxDataJob < CronJob
  self.cron_expression = "0 2 * * *"

  EDT_NAME = "Education Development Trust"
  def perform
    return if Rails.env.production?

    10.times do
      name = Faker::Name.name
      EarlyCareerTeachers::Create.call(
        full_name: name,
        email: Faker::Internet.email(name: name),
        school_cohort: random_edt_school_cohort,
        mentor_profile_id: nil,
        year_2020: false,
      )
    end

    10.times do
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name: name))
      NPQApplication.create!(
        active_alert: "",
        date_of_birth: Date.new(1990, 1, 1),
        eligible_for_funding: true,
        funding_choice: "",
        headteacher_status: "",
        nino: "",
        school_urn: random_edt_school.urn,
        teacher_reference_number: TRNGenerator.next,
        teacher_reference_number_verified: true,
        npq_course: NPQCourse.all.sample,
        npq_lead_provider: edt_npq_lead_provider,
        user: user,
      )
    end
  end

private

  def edt_ecf_lead_provider
    @edt_ecf_lead_provider ||= LeadProvider.find_by(name: EDT_NAME)
  end

  def edt_npq_lead_provider
    @edt_npq_lead_provider ||= NPQLeadProvider.find_by(name: EDT_NAME)
  end

  def random_edt_school
    @random_edt_school ||= edt_ecf_lead_provider.schools.sample
  end

  def random_edt_school_cohort
    @random_edt_school_cohort ||= SchoolCohort.find_by(school: random_edt_school, cohort: Cohort.current)
  end
end
