Feature: School leaders should be able to manage participants

  Background:
    Given scenario "school_participants" has been run
    And feature induction_tutor_manage_participants is active
    And I am logged in as existing user with email "school-leader@example.com"
    And I am on "2021 school participants" page with id "111111-hogwarts-academy"

    When I click on "link" containing "Add a new ECT or mentor"
    Then I should be on "2021 school participant type" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant type page"

  Scenario: Should be able to add a new ECT participant
    When I click the submit button
    Then "page body" should contain "Please select type of the new participant"

    When I set "new participant type radio" to "ect"
    And I click the submit button
    Then I should be on "2021 school participant details" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant etc details page"

    When I click the submit button
    Then "page body" should contain "can't be blank"

    When I type "James Bond" into field labelled "Full name"
    And I type "james.bond.007@secret.gov.uk" into field labelled "Email"
    And I click the submit button
    Then I should be on "2021 school choose etc mentor" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant choose mentor page"

    When I click the submit button
    Then "page body" should contain "can't be blank"

    When I click on "Abdul Mentor" label
    And I click the submit button
    Then I should be on "2021 school participant confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "school ect participant confirmation page"

    When I click on "link" containing "Change personal details"
    Then I should be on "2021 school participant details" page

    When I type "James Herbert Bond" into field labelled "Full name"
    And I click the submit button
    Then I should be on "2021 school choose etc mentor" page

    When I click the submit button
    Then I should be on "2021 school participant confirm" page

    When I click the submit button
    Then "page body" should contain "You have added James Herbert Bond to the 2021 cohort"
    And the page should be accessible
    And percy should be sent snapshot called "school ect participant added"

  Scenario: Should be able to add a new mentor participant
    When I click the submit button
    Then "page body" should contain "Please select type of the new participant"

    When I set "new participant type radio" to "mentor"
    And I click the submit button
    Then I should be on "2021 school participant details" page
    And the page should be accessible
    And percy should be sent snapshot called "school participant mentor details page"

    When I click the submit button
    Then "page body" should contain "can't be blank"

    When I type "James Bond" into field labelled "Full name"
    And I type "james.bond.007@secret.gov.uk" into field labelled "Email"
    And I click the submit button
    Then I should be on "2021 school participant confirm" page
    And the page should be accessible
    And percy should be sent snapshot called "school mentor participant confirmation page"

    When I click the submit button
    Then "page body" should contain "You have added James Bond to the 2021 cohort"
    And the page should be accessible
    And percy should be sent snapshot called "school mentor participant added"

  Scenario: Should see errors when email already used
    When I set "new participant type radio" to "ect"
    And I click the submit button
    And I type "Already exists" into field labelled "Full name"
    And I type "unrelated@example.com" into field labelled "Email"
    And I click the submit button
    Then "page title" should contain "This email is being used by someone at another school"
    And the page should be accessible
    And percy should be sent snapshot called "School participant email already added different school"

    When I click on "link" containing "Add a new ECT or mentor"
    Then "Early career teacher" label should be unchecked

    When I set "new participant type radio" to "ect"
    And I click the submit button
    Then "name input" should have value ""

    When I type "Already exists" into field labelled "Full name"
    And I type "dan-smith@example.com" into field labelled "Email"
    And I click the submit button
    Then "page title" should contain "This email has already been added"
    And the page should be accessible
    And percy should be sent snapshot called "School participant email already added same school"

  Scenario: Should be able to add myself as a mentor
    When I set "new participant type radio" to "self"
    And I click the submit button
    Then I should be on "2021 school participant confirm" page
    And "page body" should contain "school-leader@example.com"
    And "page body" should contain "Ms School Leader"
    And "page body" should contain "Mentor"
    And the page should be accessible
    And percy should be sent snapshot called "school self as a mentor confirmation page"

    When I click the submit button
    Then "page body" should contain "You have been added to the 2021 cohort"
    And the page should be accessible
    And percy should be sent snapshot called "school self as a mentor participant added"
