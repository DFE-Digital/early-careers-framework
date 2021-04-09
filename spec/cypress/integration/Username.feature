Feature: Changing username
  Users should be able to set a preferred name

  Background:
    Given I am logged in as "early_career_teacher" with full_name "Charles Darwin"
    Then I should be on "dashboard" page
    And the page should be accessible

  Scenario: Should be able to change username
    Then "page body" should contain "Charles Darwin"

    When I click on "edit username link"
    Then I should be on "edit username" page

    When I type "Charlie" into "name input"
    And I click the submit button
    Then I should be on "dashboard" page
    And "page body" should contain "Charlie"
    And "page body" should not contain "Charles Darwin"

    When I click on "edit username link"
    And I clear "name input"
    And I click the submit button
    Then I should be on "dashboard" page
    And "page body" should not contain "Charlie"
    And "page body" should contain "Charles Darwin"
