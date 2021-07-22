Feature: Finance user viewing finance data
  Finance users should be able to view financial data

  Background:
    Given scenario "finance_lead_providers" has been run
    And I am logged in as a "finance"

  Scenario: Finance page should list lead provider
    Then the table should have 5 rows
    Then "page body" should contain "Lead Provider"
    Then the page should be accessible
    And percy should be sent snapshot called "Finance lead providers index page"
