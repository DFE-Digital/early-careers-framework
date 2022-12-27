# frozen_string_literal: true

# Admin user

FactoryBot.create(:seed_user, full_name: "Administrator", email: "admin@example.com").tap do |admin_user|
  FactoryBot.create(:seed_admin_profile, user: admin_user)
end

Rails.logger.info("Adding a finance user")
NewSeeds::Scenarios::Users::FinanceUser
  .new(email: "finance@example.com", full_name: "Finance user")
  .build

Rails.logger.info("Adding a user with an appropriate body")
NewSeeds::Scenarios::Users::AppropriateBodyUser
  .new(email: "appropriate-body@example.com", full_name: "Appropriate body user")
  .build

Rails.logger.info("Building a delivery partner user with two delivery partners")
NewSeeds::Scenarios::Users::DeliveryPartnerUser
  .new(number: 2, email: "delivery-partner@example.com", full_name: "Delivery partner user")
  .build

Rails.logger.info("Building a lead provider user")
NewSeeds::Scenarios::Users::LeadProviderUser
  .new(email: "lead-provider@example.com", full_name: "Lead provider user")
  .build
