Feature: Resend nominations flow
  All users need to be able to attempt to resend nominations for any school

  Scenario: Resending nomination email
    Given scenario "school_with_local_authority" has been run
    And I am on "resend nominations start" page
    Then the page should be accessible
    And percy should be sent snapshot called "Resend nominations start page"

    When I click on "link" containing "Continue"
    Then I should be on "resend nominations choose location" page
    And the page should be accessible
    And percy should be sent snapshot called "Resend nominations choose location page"

    When I type "test" into "location input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    Then I should be on "resend nominations choose school" page
    And the page should be accessible
    And percy should be sent snapshot called "Resend nominations choose school page"

    When I type "test" into "school input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    Then I should be on "resend nominations review" page
    And the page should be accessible
    And percy should be sent snapshot called "Resend nominations review page"

    # Clicking change school link should reset location input
    When I click on "change school link"
    Then "location input" should have value ""

    When I type "test" into "location input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    And I type "test" into "school input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    Then I should be on "resend nominations review" page

    When I click the submit button
    Then I should be on "resend nominations success" page
    And the page should be accessible
    And percy should be sent snapshot called "Resend nominations success page"

  Scenario: Failure pages should be accessible
    When I am on "resend nominations not eligible" page
    Then the page should be accessible
    And percy should be sent snapshot called "Resend nominations not eligible page"

    When I am on "resend nominations already nominated" page
    Then the page should be accessible
    And percy should be sent snapshot called "Resend nominations already nominated page"

    When I am on "resend nominations cip only" page
    Then the page should be accessible
    And percy should be sent snapshot called "Resend nominations cip only page"

  Scenario: Resending limits
    Given scenario "school_with_local_authority" has been run
    And scenario "nomination_limit_reached" has been run
    When I am on "resend nominations start" page
    And I click on "link" containing "Continue"
    And I type "test" into "location input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    And I type "test" into "school input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button

    Then I should be on "resend nominations limit reached" page
    Then the page should be accessible
    And percy should be sent snapshot called "Resend nominations limit reached page"
