require 'faker'


Faker::Config.locale = 'en'

providers = ['Capita', 'Teach First', 'UCL', 'Best Practice Network', 'Ambition', 'Education Development Trust']
providers.each do |provider_name|
  lead_provider = LeadProvider.find_or_create_by!(name: provider_name)
  token = LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider)
  user_uuids = 10.times.each_with_object([]) do |i, uuids|
    user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.email)
    school = School.create!(urn: Faker::Internet.uuid, name: Faker::Company.name, address_line1: Faker::Address.street_address, postcode: Faker::Address.postcode)
    EarlyCareerTeacherProfile.create!(user: user, school: school)
    uuids << user.id
  end
  puts "Token for #{provider_name} is #{token}, user uuids: #{user_uuids.join(',')}"
end
