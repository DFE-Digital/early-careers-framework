Feature: Induction tutors viewing partnerships
  Induction tutors should be able to view details of their school partnership

  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as an "induction_coordinator"
    Then I should be on "choose programme" page
    And the page should be accessible

  Scenario: View partnerships
    When I click on "training provider" label
    And I click the submit button
    Then I should be on "schools" page
    And the page should be accessible

    When I click on "link" containing "2021"
    Then I am on "2021 school cohorts" page
    And "page body" should contain "Sign up with a training provider"
    And "page body" should contain "Add teachers"
    And "page body" should not contain "Choose your training"
    And the page should be accessible

    When I click on "link" containing "Sign up with a training provider"
    Then I should be on "2021 school partnerships" page
    And "page body" should contain "You need to sign a contract with a training provider so they can deliver your programme"
    And the page should be accessible
