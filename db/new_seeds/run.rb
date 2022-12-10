# frozen_string_literal: true

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

def load_base_file(file)
  base_file = Rails.root.join(*(%w[db new_seeds base] << file))

  load(base_file)
end

Rails.logger.info("Seeding database")

{
  "importing cohorts" => "add_cohorts.rb",
  "importing schedules" => "add_schedules.rb",
  "importing privacy policy 1.0" => "add_privacy_policy.rb",
  "importing core induction programmes and lead providers" => "add_core_induction_programmes_and_lead_providers.rb",
}.each do |msg, file|
  Rails.logger.info(msg)
  load_base_file(file)
end

Rails.logger.info("Adding a user with an appropriate body")
NewSeeds::Scenarios::Users::AppropriateBodyUser.new.build

Rails.logger.info("Adding a finance user")
NewSeeds::Scenarios::Users::FinanceUser.new.build

Rails.logger.info("Building two delivery partner user with two delivery partners each")
2.times { NewSeeds::Scenarios::Users::DeliveryPartnerUser.new(number: 2).build }
