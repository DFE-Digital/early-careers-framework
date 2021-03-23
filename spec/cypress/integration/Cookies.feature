Feature: Cookie page
  All ECF users need to be able to set and modify their cookie preferences

  Scenario: Preferences should not be initially set
    Given I am on "cookie" page
    Then "cookie consent radio" should be unchecked

  Scenario: Setting cookie preferences on cookie page
    Given I am on "cookie" page

    When I set "cookie consent radio" to "on"
    And I click the submit button
    Then cookie preferences have changed
    And "cookie consent radio" with value "on" is checked

    When I set "cookie consent radio" to "off"
    And I click the submit button
    Then cookie preferences have changed
    And "cookie consent radio" with value "off" is checked

    And the page should be accessible
    And percy should be sent snapshot

  Scenario: Setting preferences through banner without js
    Given I am on "start" page without JavaScript
    When I click to accept cookies
    Then cookie preferences have changed
    And "cookie consent radio" with value "on" is checked

  Scenario: Accepting cookies through banner with js
    Given I am on "start" page

    When I click to accept cookies
    Then "cookie banner" should contain "You've accepted analytics cookies."

    When I hide cookie banner
    Then "cookie banner" should be hidden

    When I navigate to "cookie" page
    Then "cookie banner" should not exist
    And "cookie consent radio" with value "on" is checked

  Scenario: Rejecting cookies through banner with js
    Given I am on "start" page

    When I click to reject cookies
    Then "cookie banner" should contain "You've rejected analytics cookies."

    When I hide cookie banner
    Then "cookie banner" should be hidden

    When I navigate to "cookie" page
    Then "cookie banner" should not exist
    And "cookie consent radio" with value "off" is checked
