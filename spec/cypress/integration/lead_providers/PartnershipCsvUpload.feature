Feature: Lead provider should be able to upload csv

  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as a "lead_provider"
    And scenario "lead_provider_with_delivery_partners" has been run

  Scenario: Upload a csv
    Given I am on "partnership csv uploads" page
    When I add a school urn csv to the file input
    And I click the submit button
    Then I should be on "csv errors" page
    And the page should be accessible
    And percy should be sent snapshot