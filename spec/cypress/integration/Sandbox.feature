Feature: Sandbox landing page
  Scenario: Visiting the Lead Providers sandbox landing page
    Given I am on "the sandbox landing page" page
    Then the page should be accessible
    And percy should be sent snapshot

  Scenario: Continuing as a Lead Provider
    Given I am on "the sandbox landing page" page
    When I click on "link" containing "Continue as an ECF training provider"
    Then I should be on "the Lead Provider landing page" page
