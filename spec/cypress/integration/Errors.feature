Feature: Error pages
  Scenario: Seeing the Not Found page
    Given I am on "not found" error page
    Then the page should be accessible
    And percy should be sent snapshot

  Scenario: Seeing the Internal Server Error page
    Given I am on "internal server error" error page
    Then the page should be accessible
    And percy should be sent snapshot

  Scenario: Seeing the Forbidden page
    Given I am on "forbidden" error page
    Then the page should be accessible
    And percy should be sent snapshot