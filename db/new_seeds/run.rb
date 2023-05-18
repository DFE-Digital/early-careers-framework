# frozen_string_literal: true

SEED_QUANTITIES = YAML.load_file(Rails.root.join("config/seed_quantities.yml"), aliases: true).fetch(Rails.env).freeze

Faker::Config.locale = "en-GB"

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

def load_base_file(file)
  base_file = Rails.root.join("db", "new_seeds", "base", file)

  load(base_file)
end

Rails.logger.info("Seeding database")

def seed_quantity(key)
  name = key.to_s

  ENV.fetch("SEED_#{name.upcase}") { SEED_QUANTITIES.fetch(name) }
end

[
  "add_cohorts.rb",
  "add_schedules.rb",
  "add_privacy_policy.rb",
  "add_lead_providers_and_cips.rb",
  "add_npq_courses.rb",
  "add_contracts.rb",
  "add_statements.rb",
  "add_appropriate_bodies.rb",
  "add_schools_and_local_authorities.rb",
  "add_users.rb",
  "add_npq_registrations.rb",
  "add_transfer_scenarios.rb",
  "add_mentor_scenarios.rb",
  "add_api_tokens.rb",
  "add_feature_flags.rb",
  "add_sit_nominations.rb",
  "add_ects_becoming_mentors.rb",
  "add_training_record_state_examples.rb",
].each do |file|
  Rails.logger.info("seeding #{file}")
  load_base_file(file)
end
