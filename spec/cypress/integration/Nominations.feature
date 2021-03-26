Feature: Resend nominations flow
  All users need to be able to attempt to resend nominations for any school

  Scenario: Resending nomination email
    Given scenario "school_with_local_authority" has been run
    And I am on "resend nominations choose location" page
    Then the page should be accessible

    When I type "test" into "location input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    Then I am on "resend nominations choose school" page
    And the page should be accessible

    When I type "test" into "school input"
    And I click on "autocomplete dropdown item" containing "Test"
    And I click the submit button
    Then I am on "resend nominations review" page
    And the page should be accessible

    When I click the submit button
    Then I am on "resend nominations success" page
    And the page should be accessible

  Scenario: Failure pages should be accessible
    When I am on "resend nominations not eligible" page
    Then the page should be accessible

    When I am on "resend nominations already nominated" page
    Then the page should be accessible

    When I am on "resend nominations limit reached" page
    Then the page should be accessible
