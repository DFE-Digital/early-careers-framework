Feature: Sign In Email
  Users will be able to login using email notifications being sent

  Scenario: Login as an Admin User to receive notification with magic link
    Given Admin account was created with "admin-test@example.com"
    And I am on "users sign in" page
    When I type "admin-test@example.com" into "email input"
    And I click the submit button
    Then An email sign in notification should be sent for email "admin-test@example.com"
    And I should be able to login with magic link for email "admin-test@example.com"

  Scenario: Login as an Lead Provider User to receive notification with magic link
    Given Lead Provider account was created with "lead-provider-test@example.com"
    And I am on "users sign in" page
    When I type "lead-provider-test@example.com" into "email input"
    And I click the submit button
    Then An email sign in notification should be sent for email "lead-provider-test@example.com"
    And I should be able to login with magic link for email "lead-provider-test@example.com"

  Scenario: Login as an Induction Coordinator User to receive notification with magic link
    Given Induction Coordinator account was created with "induction-coordinator-test@example.com"
    And I am on "users sign in" page
    When I type "induction-coordinator-test@example.com" into "email input"
    And I click the submit button
    Then An email sign in notification should be sent for email "induction-coordinator-test@example.com"
    And I should be able to login with magic link for email "induction-coordinator-test@example.com"