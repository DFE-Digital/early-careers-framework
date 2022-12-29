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
  "cohorts" => "add_cohorts.rb",
  "schedules" => "add_schedules.rb",
  "privacy policy 1.0" => "add_privacy_policy.rb",
  "core induction programmes and lead providers" => "add_lead_providers_and_cips.rb",
  "seed statements" => "add_seed_statements.rb",
  "users" => "add_users.rb",
  "appropriate bodies" => "add_appropriate_bodies.rb",
  "schools and local authorities" => "add_schools_and_local_authorities.rb",
  "npq registrations" => "add_npq_registrations.rb",
  "transfer scenarios" => "add_transfer_scenarios.rb",
  "mentor scenarios" => "add_mentor_scenarios.rb",
}.each do |msg, file|
  Rails.logger.info("adding #{msg}")
  load_base_file(file)
end
