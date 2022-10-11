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
    And "page body" should contain "Impersonate induction tutor"
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

  Scenario: Viewing a list of schools
    Then the table should have 9 rows
    And "page body" should contain "Enter the school’s name, postcode, URN or tutor email"
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
  
  Scenario: Impersonating an induction tutor
    When I click on "link" containing "Include this school"
    Then I should be on "admin school overview" page
    When I click on "impersonate button"
    Then "notification banner" should contain "You are impersonating Sarah Smith"
    And "notification banner" should contain "Stop impersonating"
    When I click on "stop impersonating button"
    Then I should be on "admin schools" page
