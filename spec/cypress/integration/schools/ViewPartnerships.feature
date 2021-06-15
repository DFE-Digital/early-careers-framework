Feature: Induction tutors viewing partnerships
  Induction tutors should be able to view details of their chosen induction programme

  Background:
    Given scenario "confirm_cip" has been run

  Scenario: View confirm with provider page
    Given I am logged in as existing user with email "confirm-provider@example.com"
    And I am on "2021 school partnerships" page with id "00041221-d612-46a8-a096-87ad63ff3a7d"
    Then I should be on "2021 school partnerships" page
    And "page body" should contain "Signing up with a training provider"
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: View confirmed with provider page
    Given I am logged in as existing user with email "signed-up-provider@example.com"
    And I am on "2021 school partnerships" page with id "0000bd75-31d0-4eb3-8df3-07f866e41d51"
    Then I should be on "2021 school partnerships" page
    And "page title" should contain "Signed up with a training provider"
    And "page body" should contain "Test delivery partner"
    And "page body" should contain "Test lead provider"
    And the page should be accessible
    And percy should be sent snapshot
