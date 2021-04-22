Feature: Admin user creating induction tutor
  Admin user should be able to create an induction coordinator

  Background:
    Given I am logged in as an "admin"
    And scenario "school_with_local_authority" has been run
    And I am on "admin schools" page

  Scenario: Create an induction tutor
    When I click on "link" containing "Test school"
    Then I should be on "admin school overview" page
    And "page body" should contain "Test school"
    And the page should be accessible

    When I click on "link" containing "Add induction tutor"
    Then I should be on "new admin school induction coordinator" page
    And the page should be accessible
    And percy should be sent snapshot

    When I type "John Smith" into "name input"
    And I type "j.smith@example.com" into "email input"
    And I click the submit button
    Then I should be on "admin school overview" page
    And the page should be accessible
    And "page body" should contain "John Smith"
    And "page body" should contain "j.smith@example.com"