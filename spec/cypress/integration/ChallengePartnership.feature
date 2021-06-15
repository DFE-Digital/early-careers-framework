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

  Scenario: A logged in induction tutor for FIP school challenges partnership
    Given I am logged in as existing user with email "test-subject@example.com"
    And I am on "2021 school partnerships" page with id "0000bd75-31d0-4eb3-8df3-07f866e41d51"
    When I click on "link" containing "report that your school has been confirmed incorrectly"
    Then I should be on "challenge partnership (any token)" page

    When I click on "I do not recognise this training provider" label
    And I click the submit button
    Then I should be on "challenge partnership success" page

    When I navigate to "2021 school partnerships" page with id "0000bd75-31d0-4eb3-8df3-07f866e41d51"
    Then "page body" should contain "Signing up with a training provider"

    @focus
  Scenario: A logged in induction tutor for CIP school challenges partnership
    Given I am logged in as existing user with email "test-subject2@example.com"
    And I am on "2021 school cohorts" page with id "00041221-d612-46a8-a096-87ad63ff3a7d"
    Then the page should be accessible
    And percy should be sent snapshot called "partnership notification banner"

    When I click on "link" containing "report it now"
    Then I should be on "challenge partnership (any token)" page

    When I click on "I do not recognise this training provider" label
    And I click the submit button
    Then I should be on "challenge partnership success" page

    When I navigate to "2021 school partnerships" page with id "00041221-d612-46a8-a096-87ad63ff3a7d"
    Then "page body" should contain "Signing up with a training provider"
    And "page body" should not contain "report it now"
