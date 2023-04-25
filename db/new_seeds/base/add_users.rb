# frozen_string_literal: true

Rails.logger.info("Adding an admin user")
NewSeeds::Scenarios::Users::AdminUser
  .new(email: "admin@example.com", full_name: "Admin user")
  .build

Rails.logger.info("Adding a super-user")
NewSeeds::Scenarios::Users::AdminUser
  .new(email: "super-user@example.com", full_name: "Super user")
  .build
  .with_super_user

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
  .add_mentors_and_ects

Rails.logger.info("Building a lead provider user")
NewSeeds::Scenarios::Users::LeadProviderUser
  .new(email: "lead-provider@example.com", full_name: "Lead provider user")
  .build
  .add_delivery_partners

Rails.logger.info("Building a CIP induction coordinator")
NewSeeds::Scenarios::InductionCoordinator
  .new(email: "cpd-test+tutor-1@digital.education.gov.uk", induction_programme: :cip)
  .build

Rails.logger.info("Building a FIP induction coordinator")
NewSeeds::Scenarios::InductionCoordinator
  .new(email: "cpd-test+tutor-2@digital.education.gov.uk", induction_programme: :fip)
  .build

Rails.logger.info("Building a School Leader")
NewSeeds::Scenarios::InductionCoordinator
  .new(email: "school-leader@example.com", full_name: "School Leader", induction_programme: :fip)
  .build
