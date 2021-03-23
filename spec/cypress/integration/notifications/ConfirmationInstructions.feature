Feature: Confirmation Instructions
  Users are being sent a confirmation instruction email when they register

  Scenario: Receiving an email after registering as a new user
    Given I am on register user page
    When I enter valid email of the user "new-user@example.com"
    Then An email notification should be sent
    And I should be able to login with magic link


