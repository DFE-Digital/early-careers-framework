Feature: Primary Contact Notification
  After Receiving Confirmation Token School Primary Contact is emailed

  Scenario: Primary School Contact is Emailed
    Given I am on Sign in page
    When I enter valid email of the lead provider user
    Then An email notification should be sent
    And Primary Contact email should be used for notification


