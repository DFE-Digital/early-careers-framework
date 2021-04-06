Feature: Estimate participants
  Induction tutors should be able to add estimates for teachers and mentors for a school cohort.

  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as an "induction_coordinator"
    Then I should be on "choose programme" page
    And the page should be accessible

  Scenario: Estimate Participants
    When I click on "training provider" label
    And I click the submit button
    Then I should be on "schools" page
    And the page should be accessible

    When I click on "link" containing "2021"
    Then I am on "2021 school cohorts" page
    And "page body" should contain "estimated numbers of teachers"
    And "page body" should contain "Add teachers"
    And "page body" should not contain "Choose your training"

    When I click on "link" containing "Add estimated numbers of teachers and mentors"
    Then I should be on "estimate participants" page
    And "page body" should contain "Number of ECTs"
    And "page body" should contain "Number of mentors"
    And the page should be accessible

    When I type "50" into "estimated teacher input"
    And I type "40" into "estimated mentor input"
    And I click the submit button
    Then I should have been redirected to "2021 school cohorts" page