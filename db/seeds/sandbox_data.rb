# frozen_string_literal: true

require "faker"

Faker::Config.locale = "en"

logger = Logger.new($stdout)
logger.formatter = proc do |_severity, _datetime, _progname, msg|
  "#{msg}\n"
end

cohort = Cohort.find_or_create_by!(start_year: "2021")
delivery_partner = DeliveryPartner.find_or_create_by!(name: Faker::Company.name)

providers = ["Capita", "Teach First", "UCL", "Best Practice Network", "Ambition", "Education Development Trust"]
providers.each do |provider_name|
  lead_provider = LeadProvider.find_or_create_by!(name: provider_name)
  token = LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider)

  user_uuids = lead_provider.partnerships.map(&:school).collect { |s| s.early_career_teacher_profiles.first.user_id }
  unless user_uuids.any?
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
        delivery_partner: delivery_partner,
      )

      EarlyCareerTeacherProfile.create!(user: user, school: school)
      uuids << user.id
    end
  end
  logger.info "Token for #{provider_name} is #{token}, user uuids: #{user_uuids.join(',')}"
end
