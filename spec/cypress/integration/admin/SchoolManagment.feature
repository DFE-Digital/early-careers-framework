Feature: Admin user managing schools
  Admin users should be able to view a list of schools

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/schools" has been run
    And I am on "admin schools" page

  Scenario: Viewing a school
    When  I click on "link" containing "Include this school"
    Then I should be on "admin school overview" page
    And "page body" should contain "Include this school"
    And "page body" should contain "Sarah Smith"
    And the page should be accessible

  Scenario: Viewing a list of schools
    Then the table should have 20 rows
    And the page should be accessible

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