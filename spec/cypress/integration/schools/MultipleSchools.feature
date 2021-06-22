Feature: School leaders should be able to manage multiple schools

  Background:
    Given scenario "schools/multiple_schools" has been run
    And I am logged in as existing user with email "school-leader@example.com"

  Scenario: Selecting and changing schools
    Given I am on "schools" page
    Then "page body" should contain "Test School 1"
    And "page body" should contain "Test School 2"
    And "page body" should not contain "Test School 3"
    And the page should be accessible
    And percy should be sent snapshot called "induction coordinator select school page"

    When I click on "link" containing "Test School 1"
    Then I should be on "school cohorts" page
    And "page body" should contain "Test School 1"
    And "page body" should not contain "Test School 2"
    And the page should be accessible
    And percy should be sent snapshot called "school cohorts with breadcrumb"

    When I click on "link" containing "Manage your schools"
    Then I should be on "schools" page

    When I click on "link" containing "Test School 2"
    Then I should be on "school cohorts" page
    And "page body" should contain "Test School 2"
    And "page body" should not contain "Test School 1"
