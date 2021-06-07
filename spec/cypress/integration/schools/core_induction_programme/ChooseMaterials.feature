Feature: Induction tutors choosing programmes
  Background:
    Given scenario "cip_cohort_with_school" has been run
    And I am logged in as an induction coordinator for created school
    And I navigate to "2021 school cohorts" page

  Scenario: Choosing materails for Core Induction Programme
    When I click on "link" containing "Choose your training materials"
    Then I should be on "2021 cohort CIP materials info" page
    And the page should be accessible
    And percy should be sent snapshot called "2021 cohort CIP materials info page"

    When I click on "link" containing "Continue"
    Then I should be on "2021 cohort CIP materials selection" page
    And the page should be accessible
    And percy should be sent snapshot called "2021 cohort CIP materials selection page"

    When I click the submit button
    Then "page body" should contain "Select the training materials you want to use"

    When I click on "label" containing "Awesome induction course"
    And I click the submit button
    Then I should be on "2021 cohort CIP materials success" page
    And "page body" should contain "Study materials saved"
    And the page should be accessible
    And percy should be sent snapshot called "2021 cohort CIP materials success page"

    When I click on "link" containing "Back to 2021"
    Then I should be on "2021 school cohorts" page

    When I click on "link" containing "Choose your training materials"
    Then I should be on "2021 cohort CIP materials" page
    And the page should be accessible
    And percy should be sent snapshot called "2021 cohort CIP materials page"
    And "page body" should contain "Changing your materials"
