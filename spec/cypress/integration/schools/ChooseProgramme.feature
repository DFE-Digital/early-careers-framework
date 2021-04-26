Feature: Induction tutors choosing programmes
  Induction tutors should be able to choose between the Full and Core
  induction programmes for their school and view cohorts and tasks

  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as an "induction_coordinator"
    Then I should be on "choose programme advisory" page
    And the page should be accessible

  Scenario: Choosing Core Induction Programme
    Then percy should be sent snapshot called "Choose programme advisory page"

    When I click on "link" containing "Continue"
    Then I should be on "choose programme" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose programme page"

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
    Then I should be on "schools" page
    And the page should be accessible
    And percy should be sent snapshot called "Schools page"

    When I am on "choose programme" page
    Then I should have been redirected to "schools" page

    When I click on "link" containing "2021"
    Then I am on "2021 school cohorts" page
    And the page should be accessible
    And percy should be sent snapshot called "2021 school cohorts page"
    And "page body" should contain "Choose your training"
    And "page body" should contain "Add early career teachers"

  Scenario: Choosing Full Induction Programme
    When I click on "link" containing "Continue"
    Then I should be on "choose programme" page

    When I click on "training provider" label
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "Confirm materials FIP page"

    When I click the submit button
    Then I should be on "choose programme success" page

    When I click on "link" containing "Continue"
    Then I should be on "schools" page
    And the page should be accessible

    When I click on "link" containing "2021"
    Then I am on "2021 school cohorts" page
    And "page body" should contain "Add early career teachers"
    And "page body" should not contain "Choose your training"
