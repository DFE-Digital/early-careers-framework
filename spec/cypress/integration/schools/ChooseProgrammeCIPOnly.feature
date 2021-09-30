Feature: Induction tutors choosing programmes

  Background:
    Given scenario "cip_only_school" has been run
    And cohort was created with start_year "2021"
    And I am logged in as an induction coordinator for created school
    Then I should be on "choose programme" page

  Scenario: Choosing the school funded fip programme
    When I click on "use a training provider funded by your school radio button"
    And I click the submit button
    Then I should be on "choose programme confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "Confirm school funded fip page"

    When I click the submit button

    Then I should be on "school funded fip success" page
    And the page should be accessible
    And percy should be sent snapshot called "school funded fip success"
