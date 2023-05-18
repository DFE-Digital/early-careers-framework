Feature: Induction tutors choosing programmes
  Induction tutors should be able to choose between the Full and Core
  induction programmes for their school and view cohorts and tasks

  Background:
    Given cohort was created as "current"
    And school was created with name "Test School" and slug "test-school"
    And I am logged in as an induction coordinator for created school
    Then I should be on "choose programme" page
    And the page should be accessible

  Scenario: Choosing Core Induction Programme
    When I click on "accredited materials" label
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible

    When I click the submit button
    Then I should be on "have you appointed an appropriate body" page

    When I click on "No" label
    And I click the submit button
    Then I should be on "choose programme success" page
    And the page should be accessible

    When I click on "link" containing "Continue"
    Then I should be on "school cohorts" page
    And the page should be accessible

  Scenario: Choosing Full Induction Programme
    When I click on "training provider" label
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible

    When I click the submit button
    Then I should be on "have you appointed an appropriate body" page

    When I click on "No" label
    And I click the submit button
    Then I should be on "choose programme success" page

  Scenario: Choosing to design and deliver our own programme
    When I click on "design and deliver our own programme radio button"
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible

    When I click the submit button
    Then I should be on "have you appointed an appropriate body" page
    When I click on "No" label
    And I click the submit button
    Then I should be on "choose programme success" page
    And the page should be accessible

  Scenario: Choosing there are no early career teachers for this year
    When I click on "no early career teachers radio button"
    And I click the submit button

    Then I should be on "choose programme confirm" page
    And the page should be accessible

    When I click the submit button
    Then I should be on "choose programme success" page
    And the page should be accessible
