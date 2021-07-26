Feature: School leaders should be able to add participants

  Background:
    Given school was created with name "Test School" and slug "test-school"
    And cohort was created with start_year "2020"
    And core_induction_programme was created with name "Awesome induction course"
    And feature year_2020_data_entry is active
    And I am on "/schools/test-school/year-2020/start" path
    Then the page should be accessible
    And percy should be sent snapshot called "Year 2020 start page"

  Scenario: Should be able to add a new 2020 ECT participant
    When I click on "link" containing "Continue"
    Then I should be on "2020 programme choice" page
    And the page should be accessible
    And percy should be sent snapshot called "Year 2020 Programme Choice page"

    When I set "programme choice radio" to "core_induction_programme"
    And I click the submit button
    Then I should be on "2020 cip choice" page
    And the page should be accessible
    And percy should be sent snapshot called "Year 2020 CIP Choice page"

    When I click on "label" containing "Awesome induction course"
    And I click the submit button
    Then I should be on "2020 add teacher" page
    And the page should be accessible
    And percy should be sent snapshot called "Year 2020 add teacher page"

    When I type "James Bond" into field labelled "Full name"
    And I type "james.bond.007@secret.gov.uk" into field labelled "Email"
    And I click the submit button
    Then I should be on "2020 check your answers" page
    And the page should be accessible
    And percy should be sent snapshot called "Year 2020 check your answers page"

    When I click the submit button
    And the page should be accessible
    And percy should be sent snapshot called "Year 2020 ect participant added"
