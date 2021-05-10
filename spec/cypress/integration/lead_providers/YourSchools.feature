Feature: Your schools flow
  Background:
    Given cohort was created with start_year "2021"
    And I am logged in as a "lead_provider"
    And scenario "lead_provider_with_schools" has been run
    And I am on "lead providers your schools" page

  Scenario: Viewing my schools
    Then "page body" should contain "Your schools"
    And the table should have 3 rows
    And "page body" should contain "Big School"
    And "page body" should contain "Middle School"
    And "page body" should contain "Small School"
    And the page should be accessible
    And percy should be sent snapshot

  Scenario: Searching my list of schools
    When I type "900002" into "search box"
    And I press enter in "search box"
    Then "page body" should contain "Middle School"
    And "page body" should contain "900002"
    And "page body" should contain "Ace Delivery Partner"
    And the table should have 1 row

    When I clear "search box"
    And I type "small" into "search box"
    And I click on "search button"
    Then "page body" should contain "Small School"
    And "page body" should contain "900003"
    And "page body" should contain "Ace Delivery Partner"
    And the table should have 1 row

    When I clear "search box"
    And I type "ace" into "search box"
    And I click on "search button"
    Then "page body" should contain "Big School"
    And "page body" should contain "Middle School"
    And "page body" should contain "Small School"
    And "page body" should contain "900001"
    And "page body" should contain "900002"
    And "page body" should contain "900003"
    And "page body" should contain "Ace Delivery Partner"
    And the table should have 3 rows

    When I clear "search box"
    And I type "banana" into "search box"
    And I click on "search button"
    Then "page body" should contain "There are no matching results"
    And "schools table" should not exist

  Scenario: Viewing school with pupil premium uplift
    When I click on "link" containing "Big School"
    Then "page body" should contain "Big School"
    And "page body" should contain "2021 participants"
    And "page body" should contain "900001"
    And "page body" should contain "Ace Delivery Partner"
    And "page body" should contain "Pupil premium above 40%"
    And "page body" should contain "induction.tutor_1@example.com"
    And the page should be accessible
    And percy should be sent snapshot called "Lead providers school with pupil premium uplift details"

  Scenario: Viewing school with sparsity uplift
    When I click on "link" containing "Middle School"
    Then "page body" should contain "Middle School"
    And "page body" should contain "2021 participants"
    And "page body" should contain "900002"
    And "page body" should contain "Ace Delivery Partner"
    And "page body" should contain "Remote school"
    And "page body" should contain "induction.tutor_2@example.com"
    And the page should be accessible
    And percy should be sent snapshot called "Lead providers school with sparsity uplift details"

  Scenario: Viewing school with pupil premium and sparsity uplifts
    When I click on "link" containing "Small School"
    Then "page body" should contain "Small School"
    And "page body" should contain "2021 participants"
    And "page body" should contain "900003"
    And "page body" should contain "Ace Delivery Partner"
    And "page body" should contain "Pupil premium above 40% and Remote school"
    And "page body" should contain "induction.tutor_3@example.com"
    And the page should be accessible
    And percy should be sent snapshot called "Lead providers school with pupil premium and sparsity uplift details"
