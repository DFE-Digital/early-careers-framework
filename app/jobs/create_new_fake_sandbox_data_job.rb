# frozen_string_literal: true

class CreateNewFakeSandboxDataJob < CronJob
  self.cron_expression = "0 2 * * *"

  def perform
    return unless Rails.env.sandbox? || Rails.env.test?

    provider_name = "Education Development Trust"

    edt_ecf_lead_provider = LeadProvider.find_by(name: provider_name)
    edt_npq_lead_provider = NPQLeadProvider.find_by(name: provider_name)

    school = edt_ecf_lead_provider.schools.first
    school_cohort = SchoolCohort.find_by(school: school, cohort: Cohort.current)
    10.times do
      name = Faker::Name.name
      EarlyCareerTeachers::Create.call(
        full_name: name,
        email: Faker::Internet.email(name: name),
        school_cohort: school_cohort,
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
        school_urn: school.urn,
        teacher_reference_number: TRNGenerator.next,
        teacher_reference_number_verified: true,
        npq_course: NPQCourse.all.sample,
        npq_lead_provider: edt_npq_lead_provider,
        user: user,
      )
    end
  end
end
