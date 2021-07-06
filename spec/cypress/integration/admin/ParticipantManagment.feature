Feature: Admin user managing partticipants
  Admin users should be able to view a list of participants

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/school_participants" has been run
    And I am on "admin participants" page

  Scenario: Viewing a list of participants
    Then the table should have 6 rows
    And "page body" should contain "Enter the participant’s name, school’s name or URN"
    And the page should be accessible
    And percy should be sent snapshot

    When I type "Test school" into "search box"
    And I press enter in "search box"
    Then the table should have 4 row

    When I clear "search box"
    And I type "Unrelated" into "search box"
    And I click on "search button"
    Then the table should have 2 row
