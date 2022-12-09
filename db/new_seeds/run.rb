# frozen_string_literal: true

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

def load_base_file(file)
  base_file = Rails.root.join(*(%w[db new_seeds base] << file))

  load(base_file)
end

Rails.logger.info("Seeding database")

Rails.logger.info("Setting up cohorts")
load_base_file("add_cohorts.rb")

Rails.logger.info("Setting up core induction programmes and lead providers")
load_base_file("add_core_induction_programmes_and_lead_providers.rb")

Rails.logger.info("Setting up schedules")
load_base_file("add_schedules.rb")

Rails.logger.info("Adding a user with an appropriate body")
NewSeeds::Scenarios::Users::AppropriateBodyUser.new.build

Rails.logger.info("Adding a finance user")
NewSeeds::Scenarios::Users::FinanceUser.new.build
