Feature: Admin Account Created Email
  Email will be sent to the user when Admin creates their account

  Scenario: Sending Email to newly Created Admin account
    Given I am logged in as an "admin"
    And I am on "admin listing" page
    When I click on "create admin button"
    Then I should be on "admin creation" page

    When I type "Joe Wick" into "name" field
    And I type "new-admin@example.com" into "email" field
    And I click the submit button
    And "main" should contain "Joe Wick"
    And "main" should contain "new-admin@example.com"
    And I click the submit button
    Then "notification banner" should contain "User added"
    And An Admin account created email will be sent to the email "new-admin@example.com"