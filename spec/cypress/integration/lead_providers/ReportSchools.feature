Feature: Report Schools flow
  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as a "lead_provider"
    And scenario "lead_provider_with_delivery_partners" has been run

  Scenario: Visiting the start page
    Given I am on "dashboard" page
    When I click on "link" containing "Confirm your schools"
    Then I should be on "lead providers report schools start" page
    And "page body" should contain "2021"
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools start page"

  Scenario: Selecting a delivery partner and upload csv
    And I am on "lead providers report schools start" page
    When I click on "link" containing "Continue"
    Then I should be on "lead providers report schools choose delivery partner" page
    And "page body" should contain "Choose the delivery partner"
    And "page body" should contain "Delivery Partner 1"
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools choose delivery partner page"
    When I click on the delivery partner radio button
    And I click the submit button
    Then I should be on "partnership csv uploads" page
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools upload csv page"

    When I add a school urn csv with errors to the file input
    And I click the submit button
    Then I should be on "csv errors" page
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools csv error page"

    When I click on "link" containing "Re-upload CSV"
    Then I should be on "partnership csv uploads" page

    When I add a school urn csv to the file input
    And I click the submit button
    Then I should be on "confirm partnerships" page
    And the table should have 2 rows
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools confirm"

    When I click on first "remove button"
    Then I should be on "confirm partnerships" page
    And the table should have 1 rows
    And "notification banner" should contain "Success"

    When I click on "input" containing "Confirm"
    Then I should be on "partnerships success" page
    And the page should be accessible
    And percy should be sent snapshot called "Lead provider report schools success"
