Feature: Induction tutors viewing partnerships
  Induction tutors should be able to view details of their chosen induction programme

  Background:
    Given scenario "confirm_cip" has been run

  Scenario: View confirm with provider page
    Given I am logged in as existing user with email "confirm-provider@example.com"
    And I am on "2021 school partnerships" page
    Then I should be on "2021 school partnerships" page
    And "page body" should contain "Have you signed up with a training provider?"
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: View confirmed with provider page
    Given I am logged in as existing user with email "signed-up-provider@example.com"
    And I am on "2021 school partnerships" page
    Then I should be on "2021 school partnerships" page
    And "page title" should contain "Sign up with a training provider"
    And "page body" should contain "Test delivery partner"
    And "page body" should contain "Test lead provider"
    And the page should be accessible
    And percy should be sent snapshot
