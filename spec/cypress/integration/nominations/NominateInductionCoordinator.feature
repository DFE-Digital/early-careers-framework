Feature: Nominate induction tutor

  Scenario: Valid Nomination Link was sent
    Given nomination_email was created with token "foo-bar-baz"
    And I am on "start nominations with token" page
    Then the page should be accessible

    When I click on "link" containing "Start"
    Then the page should be accessible

    When I type "John Smith" into "name input"
    And I type "john-smith@example.com" into "email input"
    And I click the submit button
    Then "success panel" should contain "Induction tutor nominated"
    And Email should be sent to Nominated School Induction Coordinator to email "john-smith@example.com"
    And the page should be accessible

  Scenario: Expired Nomination Link was sent
    Given nomination_email was created as "expired_nomination_email" with token "foo-bar-baz"
    And I am on "start nominations with token" page
    Then "page body" should contain "This link has expired"
    And the page should be accessible

    When I click the submit button
    Then "page body" should contain "Your school has been sent a link"
    And Email should be sent to Primary Email Contact of the School belonging to "primary-contact-email@example.com"

  Scenario: Nomination Link was sent for which Induction Tutor was already nominated for the same school
    Given nomination_email was created as "already_nominated_induction_tutor" with token "foo-bar-baz"
    When I am on "start nominations with token" page
    Then "page body" should contain "An induction tutor has already been nominated for your school"
    And the page should be accessible

  Scenario: Nomination Link was sent for which Induction Tutor was already nominated for another school
    Given nomination_email was created as "email_address_already_used_for_another_school" with token "foo-bar-baz"
    When I am on "start nominations with token" page
    Then I click on "link" containing "Start"
    Then I type "John Wick" into "name input"
    And I type "john-wick@example.com" into "email input"

    When I click the submit button
    Then "page body" should contain "The email you entered is used by another school"
    And the page should be accessible
