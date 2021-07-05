Feature: School leaders should be able to manage participants

  Background:
    Given scenario "school_participants" has been run
    And feature induction_tutor_manage_participants is active
    And I am logged in as existing user with email "school-leader@example.com"
    And I am on "2021 school participants" page with id "111111-hogwarts-academy"

  Scenario: Should be able to view participants
    Then the table should have 3 rows
    And "page body" should contain "Abdul Mentor"
    And "page body" should contain "Dan Smith"
    And "page body" should not contain "Unrelated user"
    And the page should be accessible
    And percy should be sent snapshot called "Participants index page"

    When I click on "link" containing "Joe Bloggs"
    Then I should be on "2021 school participant" page
    And the page should be accessible
    And percy should be sent snapshot called "Participant show page"

    When I click on "link" containing "Abdul Mentor"
    Then I should be on "2021 school participant" page
    And "page body" should contain "Abdul Mentor"
    And "page body" should not contain "Joe Bloggs"

  Scenario: Assigning a mentor
    When I click on "link" containing "Assign mentor"
    Then I should be on "2021 school edit ect mentor" page
    And the page should be accessible
    And percy should be sent snapshot

    When I click on "Abdul Mentor" label
    And I click the submit button
    Then I should be on "2021 school participant" page
    And "page body" should contain "The mentor for this participant has been updated"
    And "page body" should contain "Abdul Mentor"

    When I navigate to "2021 school participants" page with id "111111-hogwarts-academy"
    Then "page body" should not contain "Assign mentor"


  Scenario: Updating details of a participant
    When I click on "link" containing "Dan Smith"
    Then I should be on "2021 school participant" page

    When I click on "link" containing "Change email"
    Then I should be on "2021 school participant edit email" page
    And the page should be accessible
    And percy should be sent snapshot called "induction tutor edit participant email"

    When I type "james.bond.007@secret.gov.uk" into field labelled "Email"
    And I click the submit button
    Then I should be on "2021 school participant" page
    And "page body" should contain "Dan Smith"
    And "page body" should contain "james.bond.007@secret.gov.uk"
    And "page body" should contain "The participant's email address has been updated"
    And "page body" should not contain "dan-smith@example.com"

    When I click on "link" containing "Change name"
    Then I should be on "2021 school participant edit name" page
    And the page should be accessible
    And percy should be sent snapshot called "induction tutor edit participant name"

    When I type "New Name" into field labelled "Full name"
    And I click the submit button
    Then I should be on "2021 school participant" page
    And "page body" should contain "New Name"
    And "page body" should contain "james.bond.007@secret.gov.uk"
    And "page body" should contain "The participant's name has been updated"
    And "page body" should not contain "Dan Smith"

    Given I am on "2021 school participant edit email used" page with school_slug "111111-hogwarts-academy" and participant_id "51223b41-a562-4d94-b50c-0ce59a8bb34d"
    Then the page should be accessible
    And percy should be sent snapshot called "induction tutor edit participant email used in same school"
