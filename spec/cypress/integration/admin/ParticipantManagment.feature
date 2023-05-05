Feature: Admin user managing participants
  Admin users should be able to view a list of participants

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/school_participants" has been run
    And I am on "admin participants" page

  Scenario: Viewing a list of participants
    Then the table should have 7 rows
    And "page body" should contain "Enter the participant’s ID, name, email address or TRN"
    And the page should be accessible

    When I type "example" into "search box"
    And I press enter in "search box"
    Then the table should have 3 rows

    When I clear "search box"
    And I type "Unrelated" into "search box"
    And I click on "search button"
    Then the table should have 2 rows

  Scenario: Validating NPQ participants
    When I click on "link" containing "Natalie Portman Quebec"
    Then I should be on "admin participant" page
    And "page body" should contain "Date of birth"
    And the page should be accessible

    When I click on "link" containing "View identity confirmation"
    Then I should be on "admin participant identity" page
    And the page should be accessible

    When I click the submit button
    Then "page body" should contain "can't be blank"

    When I click on "label" containing "Approved"
    And I type "Look good to me" into field labelled "Decision notes"
    And I click the submit button
    Then I should be on "admin participant" page
    And "page body" should contain "Participant task 'Identity' has been approved"

  Scenario: Deleting a participant
    When I click on "link" containing "ECT User 1"
    Then I should be on "admin participant" page

    # Move this to ParticipantManagement.feature once the links work
    When I click on "link" containing "Delete participant"
    Then I should be on "admin delete participant" page
    And the page should be accessible

    When I click the submit button
    Then "page body" should contain "has been deleted"
    And the page should be accessible

    When I click on "link" containing "View participant listing"
    Then I should be on "admin participants" page
    # FIXME: Deleting doesn't actually delete, it removes them from a school
    #        but they'll still be visible in the list of participants
    And "page body" should contain "ECT User 1"
