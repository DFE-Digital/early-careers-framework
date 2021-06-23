Feature: Admin user creating induction tutor
  Admin user should be able to create an induction coordinator

  Background:
    Given I am logged in as an "admin"

  Scenario: Create an induction tutor
    Given scenario "school_with_local_authority" has been run
    And I am on "admin schools" page

    When I click on "link" containing "Test school"
    Then I should be on "admin school overview" page
    And "page body" should contain "Test school"
    And the page should be accessible

    When I click on "link" containing "Add induction tutor"
    Then I should be on "new admin school induction coordinator" page
    And the page should be accessible
    And percy should be sent snapshot called "Admin add induction coordinator page"

    Given user was created as "induction_coordinator" with email "existing_induction_coordinator@example.com" and full_name "Existing User"
    When I type "John Smith" into "name input"
    And I type "existing_induction_coordinator@example.com" into "email input"
    And I click the submit button
    Then "page body" should contain "The name you entered does not match our records"
    And the page should be accessible
    And percy should be sent snapshot called "Admin add induction coordinator name different"

    When I click on "link" containing "Change name"
    And I type "John Smith" into "name input"
    And I type "j.smith@example.com" into "email input"
    And I click the submit button
    Then I should be on "admin school overview" page
    And the page should be accessible
    And "page body" should contain "John Smith"
    And "page body" should contain "j.smith@example.com"
    And "notification banner" should contain "Success"
    And "notification banner" should contain "New induction tutor added"
    And "notification banner" should contain "They will get an email with next steps"

  Scenario: Update an induction tutor
    Given scenario "school_with_induction_tutor" has been run
    And I am on "admin schools" page

    When I click on "link" containing "Induction High School"
    Then I should be on "admin school overview" page
    And "page body" should contain "Induction High School"
    And the page should be accessible

    When I click on "link" containing "Change"
    Then I should be on "choose replace or update induction tutor" page
    And the page should be accessible
    And percy should be sent snapshot called "choose replace or update induction tutor"

    When I click on "update induction tutor" 
    And I click the submit button
    Then I should be on "edit admin school induction coordinator" page
    And "name input" should have value "Brenda Walsh"
    And "email input" should have value "brenda.walsh@school.org"
    And the page should be accessible
    And percy should be sent snapshot called "update induction tutor"

    When I clear "name input"
    And I type "Brenda Jones" into "name input"
    And I clear "email input"
    And I type "brenda.jones@school.org" into "email input"
    And I click the submit button
    Then I should be on "admin school overview" page
    And the page should be accessible
    And "page body" should contain "Brenda Jones"
    And "page body" should contain "brenda.jones@school.org"
    And "notification banner" should contain "Success"
    And "notification banner" should contain "Induction tutor details updated"

  Scenario: Replace an induction tutor
    Given scenario "school_with_induction_tutor" has been run
    And I am on "admin schools" page

    When I click on "link" containing "Induction High School"
    Then I should be on "admin school overview" page
    And "page body" should contain "Induction High School"
    And the page should be accessible

    When I click on "link" containing "Change"
    Then I should be on "choose replace or update induction tutor" page

    When I click on "replace induction tutor" 
    And I click the submit button
    Then I should be on "new admin school induction coordinator" page

    When I type "Megan Johnson" into "name input"
    And I clear "email input"
    And I type "megan.johnson@school.org" into "email input"
    And I click the submit button
    Then I should be on "admin school overview" page
    And the page should be accessible
    And "page body" should contain "Megan Johnson"
    And "page body" should contain "megan.johnson@school.org"
    And "page body" should not contain "Brenda Walsh"
    And "page body" should not contain "brenda.walsh@school.org"
    And "notification banner" should contain "Success"
    And "notification banner" should contain "New induction tutor added"
    And "notification banner" should contain "They will get an email with next steps"
