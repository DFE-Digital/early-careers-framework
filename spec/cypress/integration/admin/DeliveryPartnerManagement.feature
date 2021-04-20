Feature: Admin user modifying delivery partners
  Admin users should be able to create and delete delivery partners

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/suppliers" has been run
    And I am on "delivery partner index" page

  Scenario: Creating a new delivery partner
    When I click on "create delivery partner button"
    Then I should be on "choose new delivery partner name" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose new deivery partner name page"

    When I type "New delivery partner" into "delivery partner name input"
    And I click the submit button
    Then I should be on "choose new delivery partner lead providers" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose new delivery partner lead providers page"

    When I click on "Lead Provider 1" label
    And I click the submit button
    Then I should be on "choose delivery partner cohorts" page
    And the page should be accessible
    And percy should be sent snapshot called "Choose delivery partner cohorts page"

    When I click on "2021" label
    And I click the submit button
    Then I should be on "new delivery partner review" page
    And "page body" should contain "New delivery partner"
    And "page body" should contain "Lead Provider 1"
    And "page body" should contain "2021"
    And the page should be accessible
    And percy should be sent snapshot called "New delivery partner review page"

    When I click the submit button
    Then I should be on "delivery partner index" page
    And "page body" should contain "New delivery partner"
    And "notification banner" should contain "Delivery partner created"
    And the page should be accessible
    And percy should be sent snapshot called "New delivery partner index page"

  Scenario: It should remember details when navigating backwards in creation process
    When I click on "create delivery partner button"
    And I type "New delivery partner" into "delivery partner name input"
    And I click the submit button
    And I click the back link
    Then "delivery partner name input" should have value "New delivery partner"

    When I click the submit button
    And I click on "Lead Provider 1" label
    And I click the submit button
    And I click on "2021" label
    And I click the submit button
    And I click the back link
    Then "Lead Provider 1" label should be checked

    When I click the submit button
    Then "2021" label should be checked

  Scenario: It should allow changing name choice during creation
    When I click on "create delivery partner button"
    And I type "wrong name" into "delivery partner name input"
    And I click the submit button
    And I click on "Lead Provider 1" label
    And I click the submit button
    And I click on "2021" label
    And I click the submit button
    And I click on "change name link"
    And I clear "delivery partner name input"
    And I type "New delivery partner" into "delivery partner name input"
    And I click the submit button
    And I click the submit button
    And I click the submit button
    Then "page body" should contain "New delivery partner"

    When I click the submit button
    Then I should be on "delivery partner index" page
    And "page body" should contain "New delivery partner"

  Scenario: Admins should be able to edit delivery partners
    When I click on "link" containing "Delivery Partner 1"
    Then I should be on "delivery partner edit" page
    And "delivery partner name input" should have value "Delivery Partner 1"
    # And the page should be accessible
    And percy should be sent snapshot called "Delivery partner edit page"

    When I clear "delivery partner name input"
    And I type "New delivery partner" into "delivery partner name input"
    And I click on "Lead Provider 1" label
    And I click the submit button
    Then I should be on "delivery partner index" page
    And "page body" should contain "New delivery partner"
    And "page body" should not contain "Delivery Partner 1"

    When I click on "link" containing "New delivery partner"
    Then "Lead Provider 1" label should be unchecked

    # Should be able to go back to suppliers page
    When I click the back link
    Then I should be on "delivery partner index" page

  Scenario: Admins should be able to delete delivery partners
    When I click on "link" containing "Delivery Partner 1"
    And I click on "delete button"
    Then I should be on "delivery partner delete" page
    And the page should be accessible
    And percy should be sent snapshot called "Delivery partner delete page"

    When I click on "delete button"
    Then I should be on "delivery partner index" page
    And "page body" should not contain "Delivery Partner 1"
    And "notification banner" should contain "Delivery partner deleted"

  Scenario: Admins should be able to click back to edit page when deleting delivery partners
    When I click on "link" containing "Delivery Partner 1"
    And I click on "delete button"
    Then I should be on "delivery partner delete" page

    When I click on "back button"
    Then I should be on "delivery partner edit" page
