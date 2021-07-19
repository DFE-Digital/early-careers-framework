Feature: Lead Providers API Guidance
  Scenario: Visiting the Lead Providers API Guidance
    Given I am on "API guidance home" page
    Then the page should be accessible
    And percy should be sent snapshot

  Scenario: Accessing the ECF usage guide
    Given I am on "API guidance home" page
    When I click on "link" containing "ECF usage guide"
    Then I should be on "ECF usage guide" page
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: Accessing the NPQ usage guide
    Given I am on "API guidance home" page
    When I click on "link" containing "NPQ usage guide"
    Then I should be on "NPQ usage guide" page
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: Accessing the API release notes
    Given I am on "API guidance home" page
    When I click on "link" containing "Release notes"
    Then I should be on "API release notes" page
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: Accessing the API guidance support
    Given I am on "API guidance home" page
    When I click on "link" containing "Get help"
    Then I should be on "API guidance support" page
    And the page should be accessible
    And percy should be sent snapshot
