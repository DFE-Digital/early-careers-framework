Feature: Induction tutors seeing challenge banners
  Induction tutors should be able to see a banner informing them that
  they have ben recruited by a provider when they have chosen an opt-out
  programme

  Background:
    Given cohort was created with start_year "2021"
    And scenario "school_opted_out_but_was_recruited" has been run
    And I am logged in as existing user with email "ted.tutor@example.com"
    Then I should be on "school cohorts" page
    And the page should be accessible

  Scenario: Viewing the next steps page
    When I click on "link" containing "View Details"
    Then I should be on "2021 school cohorts" page
    And the page should be accessible
    And percy should be sent snapshot called "Opted out with banner"
    And "page body" should contain "Important"
    And "page body" should contain "Ranchero Partners, with Fab Provider, has confirmed your school"
