Feature: Admin user modifying admin users
  Admin users should be able to create and delete other admin accounts

  Background:
    Given I am logged in as an "admin"
    And user was created as "admin" with email "emma-dow@example.com" and full_name "Emma Dow"
    And I am on "admin index" page

  Scenario: Creating a new admin user
    When I click on "create admin button"
    Then I should be on "admin creation" page
    And the page should be accessible

    When I type "John Smith" into "name input"
    And I type "j.smith@example.com" into "email input"
    And I click the submit button
    Then I should be on "admin confirm creation" page
    And the page should be accessible
    And "page body" should contain "John Smith"
    And "page body" should contain "j.smith@example.com"

    When I click the submit button
    Then "page body" should contain "John Smith"
    And "page body" should contain "j.smith@example.com"
    And "notification banner" should contain "Success"
    And "notification banner" should contain "User added"
    And "notification banner" should contain "They have been sent an email to sign in"
    And the page should be accessible
    And An Admin account created email should be sent to the email "j.smith@example.com"

  Scenario: Deleting an admin user
    When I click on "edit admin link" containing "Emma Dow"
    Then "page body" should contain "Edit user details"
    And the page should be accessible

    When I click on "delete button"
    Then "page body" should contain "Do you want to delete this user?"
    And "page body" should contain "Admin user: Emma Dow"
    And the page should be accessible

    When I click on "delete button"
    Then "page body" should not contain "Emma Dow"
    And "page body" should contain "User deleted"
