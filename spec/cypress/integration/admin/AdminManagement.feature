Feature: Admin user modifying admin users
  Admin users should be able to create and delete other admin accounts

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/administrators/manage_admin_users" has been ran
    And I am on "admin admin" page

  Scenario: Creating a new admin user
    When I click on "create admin button"
    Then I should be on "admin admin creation" page

    When I type "John Smith" into "name" field
    And I type "j.smith@example.com" into "email" field
    And I click the submit button
    Then I should be on "admin admin confirm creation" page
    And "main" should contain "John Smith"
    And "main" should contain "j.smith@example.com"

    When I click the submit button
    Then "main" should contain "John Smith"
    And "main" should contain "j.smith@example.com"
    And "notification banner" should contain "Success"
    And "notification banner" should contain "User added"
    And "notification banner" should contain "They have been sent an email to sign in"

  Scenario: Deleting an admin user
    When I click on "edit admin link" containing "Emma Dow"
    Then "main" should contain "Edit user details"

    When I click on "delete button"
    Then "main" should contain "Do you want to delete this user?"
    And "main" should contain "Admin user: Emma Dow"

    When I click on "delete button"
    Then "main" should not contain "Emma Dow"
    And "main" should contain "User deleted"

  Scenario: Creation flow accessiblity
    Given I am on "admin admin" page
    Then the page should be accessible

    When I click on "create admin button"
    Then the page should be accessible

    When I type "John Smith" into "name" field
    And I type "j.smith@example.com" into "email" field
    And I click the submit button
    Then the page should be accessible

  Scenario: Deletion flow accessibility
    Given I am on "admin admin" page
    Then the page should be accessible

    When I click on "edit admin link" containing "Emma Dow"
    Then the page should be accessible

    When I click on "delete button"
    Then the page should be accessible
