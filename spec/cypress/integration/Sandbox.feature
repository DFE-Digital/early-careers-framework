Feature: Sandbox page
  Scenario: Visiting the sandbox page
    Given I am on "sandbox" page
    Then the page should be accessible
    And percy should be sent snapshot
