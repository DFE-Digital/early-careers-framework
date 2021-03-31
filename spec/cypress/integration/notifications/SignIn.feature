Feature: Sign In
  Users will be able to login using email notifications being sent

  Scenario: Login as an Admin User to receive notification with magic link
    Given user was created as "admin" with email "admin-test@example.com"
    And I am on "users sign in" page
    When I type "admin-test@example.com" into "email input"
    And I click the submit button
    Then An email sign in notification should be sent to the email "admin-test@example.com"
    And I should be able to login with magic link for email "admin-test@example.com"

  Scenario: Login as an Lead Provider User to receive notification with magic link
    Given user was created as "lead_provider" with email "lead-provider-test@example.com"
    And I am on "users sign in" page
    When I type "lead-provider-test@example.com" into "email input"
    And I click the submit button
    Then An email sign in notification should be sent to the email "lead-provider-test@example.com"
    And I should be able to login with magic link for email "lead-provider-test@example.com"

  Scenario: Login as an Induction Coordinator User to receive notification with magic link
    Given user was created as "induction_coordinator_with_school" with email "induction-coordinator-test@example.com"
    And I am on "users sign in" page
    When I type "induction-coordinator-test@example.com" into "email input"
    And I click the submit button
    Then An email sign in notification should be sent to the email "induction-coordinator-test@example.com"
    And I should be able to login with magic link for email "induction-coordinator-test@example.com"
