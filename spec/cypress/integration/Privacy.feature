Feature: Privacy page
  Scenario: Visiting the privacy policy page
    Given privacy_policy was created
    And I am on "start" page
    When I click on "link" containing "Privacy"
    Then I should be on "privacy" page
    And the page should be accessible
