Feature: Induction tutors choosing programmes
  Induction tutors should be able to choose between the Full and Core
  induction programmes for their school

  Background: 
    Given scenario "schools/choose_programme" has been run

  Scenario: Choosing Core Induction Programme
    Given I am logged in as an "induction_coordinator"
    Then I should be on "choose programme" page
    And the page should be accessible
    
    When I click on "accredited materials" label
    And I click the submit button
    Then I should be on "schools" page
    And the page should be accessible

    When I am on "choose programme" page
    Then I should have been redirected to "schools" page

  Scenario: Choosing Full Induction Programme
    Given I am logged in as an "induction_coordinator"
    Then I should be on "choose programme" page
    And the page should be accessible

    When I click on "training provider" label
    And I click the submit button
    Then I should be on "schools" page
    And the page should be accessible