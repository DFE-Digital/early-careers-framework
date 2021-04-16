Feature: Induction tutors viewing partnerships
  Induction tutors should be able to view details of their chosen induction programme

  Background:
   Given cohort was created with start_year "2021"
    And I am logged in as an "induction_coordinator"
    Then I should be on "choose programme advisory" page
    And the page should be accessible

    When I click on "link" containing "Continue"
    Then I should be on "choose programme" page
    And the page should be accessible

  Scenario: View chosen programme
    When I click on "training provider" label
    And I click the submit button
    Then I should be on "schools" page
    And the page should be accessible

    When I click on "link" containing "2021"
    Then I am on "2021 school cohorts" page
    And "page body" should contain "Choose your induction programme"
    And "page body" should contain "Confirm your training provider"
    And "page body" should contain "Add early career teachers and mentors"
    And the page should be accessible

    When I click on "link" containing "Confirm your training provider"
    Then I should be on "2021 school partnerships" page
    And "page body" should contain "Have you confirmed which training provider your school is using?"
    And the page should be accessible
