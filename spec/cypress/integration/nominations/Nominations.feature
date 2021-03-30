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

  Scenario: Valid Nomination Link was sent
    Given Following Factory set up was run "nomination_email"
    When I go to nominations link with token "foo-bar-baz"
    Then I type "John Wick" into "name input"
    And I type "john-wick" into "email input"
    When I click the submit button
    Then "page body" should contain "School Lead has been nominated"

  Scenario: Expired Nomination Link was sent
    Given Following Factory set up was run "nomination_email expired_nomination_email"
    When I go to nominations link with nomination "foo-bar-baz"
    Then "page body" should contain "This Link has expired"
    When I click the submit button
    Then "page body" should contain "Instructions have been emailed to the school"
    And Email should be sent to Primary Email Contact of the School belonging to "primary-contact-email@example.com"


  Scenario: Non Valid Nomination Link was sent for which Induction Tutor was already nominated for the same school
    Given Following Factory set up was run "nomination_email already_nominated_induction_tutor"
    When I go to nominations link with nomination "foo-bar-baz"
    Then "page body" should contain "An Induction Tutor has already been nominated for your school"

  Scenario: Nomination Link was sent for which Induction Tutor was already nominated for another school
    Given Following Factory set up was run "nomination_email email_address_already_used_for_another_school"
    When I go to nominations link with nomination "foo-bar-baz"
    Then "page body" should contain "That email address is already associated with another school"
