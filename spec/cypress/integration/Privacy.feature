Feature: Privacy page
  Scenario: Visiting the privacy policy page
    Given I am on "start" page
    When I click on "link" containing "Privacy"
    Then I should be on "privacy" page
    And the page should be accessible
    And percy should be sent snapshot
