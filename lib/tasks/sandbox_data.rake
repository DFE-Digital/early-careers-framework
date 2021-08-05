# frozen_string_literal: true

namespace :lead_provider do
  desc "create seed mentors for API testing"
  task seed_mentors: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    providers_names = ["Capita", "Teach First", "UCL Institute of Education", "Best Practice Network", "Ambition Institute", "Education Development Trust"]
    cohort_2021 = Cohort.find_by!(start_year: "2021")

    providers_names.each_with_index do |provider_name, index|
      logger.info("Generating seed mentors for '#{provider_name}'...")
      lead_provider = LeadProvider.find_by!(name: provider_name)
      school = create_school_and_associations(lead_provider, cohort_2021, index)
      generate_mentors(lead_provider, school, cohort_2021, logger)
    end
  end
end

def generate_mentors(lead_provider, school, cohort, logger)
  existing_mentor_count = lead_provider.ecf_participant_profiles.mentors.count
  existing_ect_count = lead_provider.ecf_participant_profiles.ects.count
  school_cohort = SchoolCohort.find_or_create_by!(school: school, cohort: cohort)

  10.times do
    mentor = create_teacher
    mentor_profile = ParticipantProfile::Mentor.create!(teacher_profile: mentor, school_cohort: school_cohort)

    ect_count = rand(0..3)
    ect_count.times do
      ect = create_teacher
      ParticipantProfile::ECT.create!(teacher_profile: ect, school_cohort: school_cohort, mentor_profile: mentor_profile)
    end
    logger.info(" Mentor with user_id #{mentor.id} generated with #{ect_count} ECTs")
  end
  2.times do
    mentor = create_teacher
    mentor_profile = ParticipantProfile::Mentor.create!(teacher_profile: mentor, school_cohort: school_cohort, status: "withdrawn")

    ect = create_teacher
    ParticipantProfile::ECT.create!(teacher_profile: ect, school_cohort: school_cohort, mentor_profile: mentor_profile, status: "withdrawn")
  end
  new_mentor_count = lead_provider.ecf_participant_profiles.mentors.count
  logger.info(" Before: #{existing_mentor_count} mentors, after: #{new_mentor_count}")
  new_ect_count = lead_provider.ecf_participant_profiles.ects.count
  logger.info(" Before: #{existing_ect_count} ECTs, after: #{new_ect_count}")
end

def create_school_and_associations(lead_provider, cohort, index)
  school = School.find_or_create_by!(
    urn: sprintf("%06d", (10_000 + index)),
  ) do |s|
    s.name = Faker::Company.name
    s.address_line1 = Faker::Address.street_address
    s.postcode = Faker::Address.postcode
  end

  Partnership.find_or_create_by!(
    school: school,
    lead_provider: lead_provider,
    cohort: cohort,
  ) do |partnership|
    partnership.delivery_partner = DeliveryPartner.create!(name: Faker::Company.name)
  end

  SchoolCohort.find_or_create_by!(school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")

  school
end

def random_trn
  return if [true, false].sample

  sprintf("%07i", Random.random_number(9_999_999))
end

def create_teacher
  mentor = User.create!(full_name: Faker::Name.name, email: Faker::Internet.email)
  TeacherProfile.create!(user: mentor, trn: random_trn)
end
