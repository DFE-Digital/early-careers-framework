Feature: Admin user managing schools
  Admin users should be able to view a list of schools

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/schools" has been run
    And I am on "admin schools" page

  Scenario: Viewing a list of schools
    Then the table should have 20 rows
    And the page should be accessible

    When I type "include" into "search box" and press enter
    Then "page body" should contain "1234"
    And "page body" should contain "Include this school"
    And the table should have 1 row

    When I clear "search box"
    And I type "1234" into "search box"
    And I click on "search button"
    Then "page body" should contain "1234"
    And "page body" should contain "Include this school"
    And the table should have 1 row