Feature: Induction tutors choosing programmes
  Induction tutors should be able to choose between the Full and Core
  induction programmes for their school and view cohorts and tasks

  Background:
    Given cohort was created with start_year "2021"
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

    When I navigate to "choose programme" page with school_id "test-school" and cohort_id "2021"
    Then I should have been redirected to "school cohorts" page
    And the page should be accessible
    And "page body" should contain "Manage your training"
    And "page body" should contain "Add your early career teacher and mentor details"

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

    When I click on "link" containing "Continue"
    Then I should be on "school cohorts" page
    And the page should be accessible
    And "page body" should contain "Manage your training"
    And "page body" should contain "Add your early career teacher and mentor details"

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
