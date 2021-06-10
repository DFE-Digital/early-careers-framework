# frozen_string_literal: true

require "faker"

Faker::Config.locale = "en"

logger = Logger.new($stdout)
logger.formatter = proc do |_severity, _datetime, _progname, msg|
  "#{msg}\n"
end

cohort_2021 = Cohort.find_or_create_by!(start_year: "2021")

providers_names = ["Capita", "Teach First", "UCL", "Best Practice Network", "Ambition", "Education Development Trust"]

def generate_provider_token(lead_provider, school, cohort, logger)
  token = LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider)
  existing_user_uuids = User.participants_for_lead_provider(lead_provider).map(&:id)

  unless existing_user_uuids.any?
    user_uuids = 10.times.each_with_object([]) do |_i, uuids|
      mentor = User.create!(full_name: Faker::Name.name, email: Faker::Internet.email)
      mentor_profile = MentorProfile.create!(user: mentor, school: school, cohort: cohort)
      uuids << mentor.id

      ect = User.create!(full_name: Faker::Name.name, email: Faker::Internet.email)
      EarlyCareerTeacherProfile.create!(user: ect, school: school, cohort: cohort, mentor_profile: mentor_profile)
      uuids << ect.id
    end
  end
  output_uuids = user_uuids || existing_user_uuids
  logger.info "Token for #{lead_provider.name} is #{token}, user uuids: #{output_uuids.join(',')}"
end

def create_school_and_associations(lead_provider, cohort, index)
  school = School.find_or_create_by!(
    urn: sprintf("%06d", (10_000 + index)),
  ) do |s|
    s.name = Faker::Company.name
    s.address_line1 = Faker::Address.street_address
    s.postcode = Faker::Address.postcode
  end

  Partnership.create!(
    school: school,
    lead_provider: lead_provider,
    cohort: cohort,
    delivery_partner: DeliveryPartner.find_or_create_by!(name: Faker::Company.name),
  )

  SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")

  school
end

providers_names.each_with_index do |provider_name, i|
  lead_provider = LeadProvider.find_or_create_by!(name: provider_name)
  school = create_school_and_associations(lead_provider, cohort_2021, i)
  generate_provider_token(lead_provider, school, cohort_2021, logger)
end
