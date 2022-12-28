# frozen_string_literal: true

Faker::Config.locale = "en-GB"

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

def load_base_file(file)
  base_file = Rails.root.join(*(%w[db new_seeds base] << file))

  load(base_file)
end

Rails.logger.info("Seeding database")

# base files are simply ruby scripts we run, they contain static data and
# generic records

{
  "importing cohorts" => "add_cohorts.rb",
  "importing schedules" => "add_schedules.rb",
  "importing privacy policy 1.0" => "add_privacy_policy.rb",
  "importing core induction programmes and lead providers" => "add_lead_providers_and_cips.rb",
  "adding users" => "add_users.rb",
  "adding appropriate bodies" => "add_appropriate_bodies.rb",
  "adding schools and local authorities" => "add_schools_and_local_authorities.rb",
  "adding npq registrations" => "add_npq_registrations.rb",
  "adding transfer scenarios" => "add_transfer_scenarios.rb",
  "adding mentor scenarios" => "add_mentor_scenarios.rb",
}.each do |msg, file|
  Rails.logger.info(msg)
  load_base_file(file)
end
