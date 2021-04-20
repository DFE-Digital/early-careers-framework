Feature: Check you have an account page
  Scenario: Visiting the Check you have an account page
    Given I am on "start" page

    When I click on "link" containing "Start"
    Then I am on "users sign in" page

    When I click on "link" containing "check if you have an account"
    Then I am on "check account" page
    And the page should be accessible
    And percy should be sent snapshot
