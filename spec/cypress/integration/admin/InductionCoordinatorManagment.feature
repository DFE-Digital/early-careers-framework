  Background:
    Given I am logged in as an "admin"
    And scenario "admin/schools" has been run
    And I am on "admin schools" page

  Scenario: Viewing a school
    When I click on "link" containing "Include this school"
    Then I should be on "admin school overview" page
    And "page body" should contain "Include this school"
    And "page body" should contain "Sarah Smith"
    And "page body" should contain "Test local authority"
    And the page should be accessible
