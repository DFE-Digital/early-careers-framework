Feature: Report Schools flow
  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as a "lead_provider"

  Scenario: Visiting the start page
    Given I am on "dashboard" page
    When I click on "link" containing "Confirm your schools"
    Then I should be on "lead providers report schools start" page
    And "page body" should contain "2021"
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools start page"
