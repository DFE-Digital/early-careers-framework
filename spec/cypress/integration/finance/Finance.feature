Feature: Finance user viewing finance data
  Finance users should be able to view financial data

  Background:
    Given scenario "finance_lead_providers" has been run
    And I am logged in as a "finance"

  Scenario: Finance user can view ECF payment breakdowns
    Then I should be on "finance lead providers index" page
    And the table should have 5 rows
    And "page body" should contain "Lead Provider"
    And the page should be accessible
    And percy should be sent snapshot called "Finance lead providers index page"

    When I click on "link" containing "Lead Provider"
    Then I should be on "ECF payment breakdown" page
    And "page body" should contain "Service Fee"
    And "page body" should contain "Output Payment"
    And "page body" should contain "Other Fees"
    Then the page should be accessible
    And percy should be sent snapshot called "Finance ECF payment breakdown page"
