Feature: Choose how to continue nomination
  Background:
    Given cohort was created with start_year "2021"

  Scenario: School has early career teachers for this year
    Given nomination_email was created with token "foo-bar-baz"
    And I am on "start nominations with token" page
    Then the page should be accessible
    And percy should be sent snapshot called "Choose how to continue"

    When I click on "nominate induction tutor radio button"
    And I click the submit button
    Then "page body" should contain "Nominate an induction lead or tutor"

  Scenario: School does not have any early career teachers this year
    Given nomination_email was created with token "foo-bar-baz"
    And I am on "start nominations with token" page

    When I click on "opt out of updates radio button"
    And I click the submit button
    Then "page body" should contain "Your choice has been saved for 2021/22"
    Then the page should be accessible
    And percy should be sent snapshot called "Opt out of notifications"

  Scenario: School wants to nominate someone for updates
    Given nomination_email was created with token "foo-bar-baz"
    And I am on "start nominations with token" page

    When I click on "nominate someone for updates radio button"
    And I click the submit button
    Then "page body" should contain "Nominate an induction lead or tutor"

