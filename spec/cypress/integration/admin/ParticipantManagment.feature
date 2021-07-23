Feature: Admin user managing participants
  Admin users should be able to view a list of participants

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/school_participants" has been run
    And I am on "admin participants" page

  Scenario: Viewing a list of participants
    Then the table should have 7 rows
    And "page body" should contain "Enter the participant’s name, school’s name or URN"
    And the page should be accessible
    And percy should be sent snapshot

    When I type "Test school" into "search box"
    And I press enter in "search box"
    Then the table should have 4 rows

    When I clear "search box"
    And I type "Unrelated" into "search box"
    And I click on "search button"
    Then the table should have 2 rows

  Scenario: Validating NPQ participants
    When I click on "link" containing "Natalie Portman Quebec"
    Then I should be on "admin participant" page
    And "page body" should contain "DOB entered"
    And the page should be accessible
    And percy should be sent snapshot called "NPQ participant admin profile"

    When I click on "link" containing "View identity confirmation"
    Then I should be on "admin participant identity" page
    And the page should be accessible
    And percy should be sent snapshot called "NPQ participant admin empty identity validation"

    When I click the submit button
    Then "page body" should contain "can't be blank"

    When I click on "label" containing "Approved"
    And I type "Look good to me" into field labelled "Decision notes"
    And I click the submit button
    Then I should be on "admin participant" page
    And "page body" should contain "Participant task 'Identity' has been approved"
