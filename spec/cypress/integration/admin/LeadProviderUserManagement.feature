Feature: Admin user modifying lead provider users
  Admin users should be able to create and delete lead provider users

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/suppliers" has been run
    And user was created as "lead_provider" with full_name "John Wick" and email "john-wick@example.com"
    And I am on "lead provider users index" page

  Scenario: Creating a new lead provider user
    When I click on "create supplier user button"
    Then I should be on "new lead provider user" page
    And the page should be accessible

    When I type "Lead" into "supplier name input"
    And I click on "autocomplete dropdown item" containing "Lead Provider 1"
    And I click the submit button
    Then I should be on "new lead provider user details" page
    And the page should be accessible

    When I type "John Smith" into "name input"
    And I type "j.s@example.com" into "email input"
    And I click the submit button
    Then I should be on "new lead provider user review" page
    And the page should be accessible
    And "page body" should contain "John Smith"
    And "page body" should contain "j.s@example.com"

    When I click the submit button
    Then I should be on "lead provider users index" page
    And the page should be accessible
    And "page body" should contain "John Smith"
    And "page body" should contain "j.s@example.com"
    And "page body" should contain "Lead Provider 1"
    And "notification banner" should contain "User added"

  Scenario: Creating a new lead provider user should handle backwards navigation
    When I click on "create supplier user button"
    And I type "Lead Provider 1" into "supplier name input"
    And I click the submit button
    And I type "Wrong name" into "name input"
    And I type "j.s@example.com" into "email input"
    And I click the submit button
    And I click the back link
    Then I should be on "new lead provider user details" page
    And "name input" should have value "Wrong name"
    And "email input" should have value "j.s@example.com"

    When I clear "name input"
    And I type "John Smith" into "name input"
    And I click the submit button
    And I click the submit button
    Then I should be on "lead provider users index" page
    And "page body" should contain "John Smith"
    And "page body" should contain "j.s@example.com"
    And "page body" should contain "Lead Provider 1"
    And "notification banner" should contain "User added"

  Scenario: Should allow deleting lead provider user
    When I click on "link" containing "All users"
    Then "page body" should contain "John Wick"

    When I click on "edit supplier user link"
    And I click on "delete button"
    Then I should be on "lead provider user delete" page
    And the page should be accessible
    Then "page body" should contain "Do you want to delete this user?"
    And "page body" should contain "Supplier user: John Wick"

    When I click on "delete button"
    Then I should be on "lead provider users index" page
    And "page body" should not contain "John Wick"
    And "notification banner" should contain "User deleted"
