Feature: Induction tutors viewing partnerships
  Induction tutors should be able to view details of their chosen induction programme

  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as an "induction_coordinator"
    Then I should be on "choose programme advisory" page

    When I click on "link" containing "Continue"
    Then I should be on "choose programme" page

    When I click on "training provider" label
    And I click the submit button
    Then I should be on "schools" page

    When I click on "link" containing "2021"
    Then I am on "2021 school cohorts" page

  Scenario: View chosen programme
    When I click on "link" containing "Sign up with a training provider"
    Then I should be on "2021 school partnerships" page
    And "page body" should contain "Have you signed up with a training provider?"
    And the page should be accessible
    And percy should be sent snapshot
