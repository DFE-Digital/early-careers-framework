Feature: Resend nominations flow
  All users need to be able to attempt to resend nominations for any school

  Scenario: Valid Nomination Link was sent
  {word} was created with {}
    Given nomination_email was created with token "foo-bar-baz"
    When I am on "nominations with token" page
    Then I type "John Wick" into "name input"
    And I type "john-wick@example.com" into "email input"

    When I click the submit button
    Then "notification banner" should contain "School Lead has been nominated"
    And Email should be sent to Nominated School Induction Coordinator to email "john-wick@example.com"

  Scenario: Expired Nomination Link was sent
    Given nomination_email was created as "expired_nomination_email" with token "foo-bar-baz"
    When I am on "nominations with token" page
    Then "page body" should contain "This Link has expired"

    When I click the submit button
    Then "page body" should contain "Instructions have been emailed to the school"
    And Email should be sent to Primary Email Contact of the School belonging to "primary-contact-email@example.com"

  Scenario: Invalid Nomination Link was sent for which Induction Tutor was already nominated for the same school
    Given nomination_email was created as "already_nominated_induction_tutor" with token "foo-bar-baz"
    When I am on "nominations with token" page
    Then "page body" should contain "An Induction Tutor has already been nominated for your school"

  Scenario: Nomination Link was sent for which Induction Tutor was already nominated for another school
    Given nomination_email was created as "email_address_already_used_for_another_school" with token "foo-bar-baz"
    When I am on "nominations with token" page
    Then I type "John Wick" into "name input"
    And I type "john-wick@example.com" into "email input"

    When I click the submit button
    Then "page body" should contain "That email address is already associated with another school"