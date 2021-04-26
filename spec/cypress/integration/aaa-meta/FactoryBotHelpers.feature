Feature: factory_bot helper meta tests
  Cucumber step definitions should define helpers to interact with factory_bot

  Scenario: Should be able to log in as a new user
    Given I am logged in as "admin"
    Then "page body" should contain "Schools"

  Scenario: Should be able to log in as existing users
    Given user was created as "admin" with email "user@example.com"
    And I am logged in as existing user with email "user@example.com"
    Then "page body" should contain "Schools"
