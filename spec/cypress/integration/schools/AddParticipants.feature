Feature: School leaders should be able to manage participants

  Background:
    Given scenario "school_participants" has been run
    And feature induction_tutor_manage_participants is active
    And I am logged in as existing user with email "school-leader@example.com"
    And I am on "2021 school participants" page

  Scenario: Should be able to add a new ECT participant
    When I click on "link" containing "Add participants"
    Then I should be on "2021 school participant type" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant type page"

    When I click the submit button
    Then "page body" should contain "Please select type of the new participant"

    When I set "new participant type radio" to "ect"
    And I click the submit button
    Then I should be on "2021 school participant details" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant details page"

    When I click the submit button
    Then "page body" should contain "can't be blank"

    When I type "James Bond" into field labelled "Full name"
    And I type "james.bond.007@.secret.gov.uk" into field labelled "Email"
    And I click the submit button
    Then I should be on "2021 school participant confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant confirmation page"

    When I click the submit button
    Then "page body" should contain "Further steps not implemented"
