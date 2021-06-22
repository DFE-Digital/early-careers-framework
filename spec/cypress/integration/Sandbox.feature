Feature: Sandbox landing page
  Scenario: Visiting the Lead Providers sandbox landing page
    Given I am on "the sandbox landing page" page
    Then the page should be accessible
    And percy should be sent snapshot

  Scenario: Continuing as a Lead Provider
    Given I am on "the sandbox landing page" page
    When I click on "link" containing "Continue as a training provider"
    Then I should be on "the Lead Provider landing page" page

  Scenario: Continuing as a Lead Provider
    Given I am on "the sandbox landing page" page
    When I click on "link" containing "Review our API documentation"
    Then I should be on "API Documentation" page
