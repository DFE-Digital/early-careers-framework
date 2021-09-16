Feature: Induction tutors choosing programmes
  Induction tutors should be able to choose between the Full and Core
  induction programmes for their school and view cohorts and tasks

  Background:
    Given cohort was created with start_year "2021"
    And school was created with name "Test School" and slug "test-school"
    And I am logged in as an induction coordinator for created school
    Then I should be on "choose programme" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose programme page"

  Scenario: Choosing Core Induction Programme
    When I click on "accredited materials" label
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "Confirm materials CIP page"

    When I click the submit button
    Then I should be on "choose programme success" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose materials success"

    When I click on "link" containing "Continue"
    Then I should be on "school cohorts" page
    And the page should be accessible
    And percy should be sent snapshot called "CIP schools page"

    When I navigate to "choose programme" page with id "test-school"
    Then I should have been redirected to "school cohorts" page
    And the page should be accessible
    And "page body" should contain "Manage your training"
    And "page body" should contain "Add your early career teacher and mentor details"
    And percy should be sent snapshot called "Manage your training page"

  Scenario: Choosing Full Induction Programme
    When I click on "training provider" label
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "Confirm materials FIP page"

    When I click the submit button
    Then I should be on "choose programme success" page

    When I click on "link" containing "Continue"
    Then I should be on "school cohorts" page
    And the page should be accessible
    And "page body" should contain "Manage your training"
    And "page body" should contain "Add your early career teacher and mentor details"
    And percy should be sent snapshot called "FIP schools page"

  Scenario: Choosing to design and deliver our own programme
    When I click on "design and deliver our own programme radio button"
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "Confirm materials DIY page"

    When I click the submit button

    Then I should be on "design your programme success" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose design and deliver success"

  Scenario: Choosing there are no early career teachers for this year
    When I click on "no early career teachers radio button"
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "Confirm materials no ECT page"

    When I click the submit button
    Then I should be on "no early career teachers success" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose no early career teachers success"
