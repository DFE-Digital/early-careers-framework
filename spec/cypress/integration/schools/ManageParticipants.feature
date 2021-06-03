Feature: School leaders should be able to manage participants

  Background:
    Given scenario "school_participants" has been run
    And feature induction_tutor_manage_participants is active
    And I am logged in as existing user with email "school-leader@example.com"
    And I am on "2021 school participants" page

  Scenario: Should be able to view participants
    Then the table should have 3 rows
    And "page body" should contain "Abdul Mentor"
    And "page body" should contain "Dan Smith"
    And "page body" should not contain "Unrelated user"
    And the page should be accessible
    And percy should be sent snapshot called "Participants index page"

    When I click on "link" containing "Dan Smith"
    Then I should be on "2021 school participant" page
    And the page should be accessible
    And percy should be sent snapshot called "Participant show page"

    When I click on "link" containing "Abdul Mentor"
    Then I should be on "2021 school participant" page
    And "page body" should contain "Abdul Mentor"
    And "page body" should not contain "Dan Smith"
