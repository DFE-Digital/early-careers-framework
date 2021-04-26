Feature: Reporting an error with a partnership

  Background:
    Given scenario "challenge_partnership" has been run

  Scenario: Successfully challenging a partnership from token link
    Given I am on "challenge partnership" page with id "abc123"
    Then the page should be accessible
    And percy should be sent snapshot called "challenge options"

    When I click on "This looks like a mistake" label
    And I click the submit button
    Then I should be on "challenge partnership success" page
    And the page should be accessible
    And percy should be sent snapshot called "challenge success"

    When I am on "challenge partnership" page with id "abc123"
    Then I should have been redirected to "already challenged" page
    And the page should be accessible
    And percy should be sent snapshot called "already challenged"

  Scenario: Clicking an expired challenge link
    Given I am on "challenge partnership" page with id "expired"
    Then I should have been redirected to "challenge link expired" page
    And the page should be accessible
    And percy should be sent snapshot called "challenge link expired"

  Scenario: A logged in induction tutor challenges partnership
    Given I am logged in as existing user with email "test-subject@example.com"
    And I am on "2021 school partnerships" page
    When I click on "link" containing "report that your school has been confirmed incorrectly"
    Then I should be on "challenge partnership (any token)" page

    When I click on "I do not recognise this training provider" label
    And I click the submit button
    Then I should be on "challenge partnership success" page

    When I am on "2021 school partnerships" page
    Then "page body" should contain "Have you signed up with a training provider?"


