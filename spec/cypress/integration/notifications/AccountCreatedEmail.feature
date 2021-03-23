Feature: Account Created Email
  Email will be sent to the user when Admin creates their account

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/administrators/manage_admin_users" has been ran
    And I am on "admin listing" page

  Scenario: Sending Email to newly Created Admin account
    When I click on "create admin button"
    Then I should be on "admin creation" page
    And the page should be accessible

    When I type "Joe Wick" into "name" field
    And I type "new-admin@example.com" into "email" field
    And I click the submit button
    And "main" should contain "Joe Wick"
    And "main" should contain "new-admin@example.com"
    Then An account created email will be sent to the email "new-admin@example.com"

