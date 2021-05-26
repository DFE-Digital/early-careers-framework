# frozen_string_literal: true

require "faker"

Faker::Config.locale = "en"

logger = Logger.new($stdout)
logger.formatter = proc do |_severity, _datetime, _progname, msg|
  "#{msg}\n"
end

cohort_2021 = Cohort.find_or_create_by!(start_year: "2021")

providers_names = ["Capita", "Teach First", "UCL", "Best Practice Network", "Ambition", "Education Development Trust"]

def generate_provider_token(lead_provider, cohort, logger)
  token = LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider)
  existing_user_uuids = lead_provider.partnerships.map(&:school).map { |s| s.early_career_teacher_profiles.first&.user_id }

  unless existing_user_uuids.any?
    user_uuids = 10.times.each_with_object([]) do |_i, uuids|
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.email)

      school = School.create!(
        urn: Faker::Internet.uuid,
        name: Faker::Company.name,
        address_line1: Faker::Address.street_address,
        postcode: Faker::Address.postcode,
      )

      Partnership.create!(
        school: school,
        lead_provider: lead_provider,
        cohort: cohort,
        delivery_partner: DeliveryPartner.find_or_create_by!(name: Faker::Company.name),
      )

      EarlyCareerTeacherProfile.create!(user: user, school: school)
      uuids << user.id
    end
  end
  output_uuids = user_uuids || existing_user_uuids
  logger.info "Token for #{lead_provider.name} is #{token}, user uuids: #{output_uuids.join(',')}"
end

providers_names.each do |provider_name|
  lead_provider = LeadProvider.find_or_create_by!(name: provider_name)
  generate_provider_token(lead_provider, cohort_2021, logger)
end
