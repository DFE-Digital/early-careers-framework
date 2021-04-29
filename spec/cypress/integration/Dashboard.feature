Feature: Dashboard page
  Background:
    Given cohort was created with start_year "2021"
  Scenario: Visiting the dashboard
    Given I am logged in as a "lead_provider"
    Then I should be on "dashboard" page
    And "page body" should contain "Confirm your schools"
    And the page should be accessible
    And percy should be sent snapshot called "Dashboard page"

    When I click on "link" containing "Confirm your schools"
    Then I should be on "lead providers report schools start" page
