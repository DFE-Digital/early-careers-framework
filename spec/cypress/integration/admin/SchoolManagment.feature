Feature: Admin user managing schools
  Admin users should be able to view a list of schools

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/schools" has been run
    And I am on "admin schools" page

  Scenario: Viewing a school
    When I click on "link" containing "Include this school"
    Then I should be on "admin school overview" page
    And "page body" should contain "Include this school"
    And "page body" should contain "Sarah Smith"
    And "page body" should contain "Test local authority"
    And the page should be accessible

  Scenario: Viewing a school's cohorts
    When I click on "link" containing "Cohort School"
    Then I should be on "admin school overview" page

    When I click on "link" containing "Cohorts"
    Then I should be on "admin school cohorts" page
    And "page body" should contain "Cohort School"
    And "page body" should contain "CIP Programme 1"
    And "page body" should contain "CIP Programme 2"
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: Viewing a list of schools
    Then the table should have 20 rows
    And the page should be accessible
    And percy should be sent snapshot

    When I type "include" into "search box"
    And I press enter in "search box"
    Then "page body" should contain "123456"
    And "page body" should contain "Include this school"
    And the table should have 1 row

    When I clear "search box"
    And I type "123456" into "search box"
    And I click on "search button"
    Then "page body" should contain "123456"
    And "page body" should contain "Include this school"
    And the table should have 1 row
