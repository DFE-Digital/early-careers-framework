Feature: Start Page
  Visiting Start Page

  Scenario: Should have feedback link
    When I am on "start" page
    Then "phase banner" should contain "feedback"
    And the page should be accessible

