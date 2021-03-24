Feature: Primary Contact Notification
  After Receiving Confirmation Token School Primary Contact is emailed

  Scenario: Primary School Contact is Emailed
    Given Induction Coordinator account was created with "induction-coordinator-test@example.com"
    And I am on "users sign in" page
    When I type "induction-coordinator-test@example.com" into "email" field
    And I click the submit button
    Then An email sign in notification should be sent for email "induction-coordinator-test@example.com"
    And I should be able to login with magic link for email "induction-coordinator-test@example.com"
    And Email should be sent to Primary Email Contact of the School belonging to "school_primary_contact_email@example.com"


