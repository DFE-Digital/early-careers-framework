Feature: Accessibility statement page
  Scenario: Visiting the accessibility statement policy page
    Given I am on "start" page
    When I click on "link" containing "Accessibility"
    Then I should be on "accessibility" page
    And the page should be accessible
    And percy should be sent snapshot
