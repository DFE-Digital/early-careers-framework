Feature: Admin user modifying delivery partners
  Admin users should be able to create and delete delivery partners

  Background:
    Given I am logged in as an "admin"
    And scenario "admin/suppliers/create_supplier" has been ran
    And I am on "delivery supplier listing" page

  Scenario: Creating a new delivery partner
    When I click on "create delivery partner button"
    Then I should be on "choose new delivery partner name" page
    And the page should be accessible

    When I type "New delivery partner" into "delivery partner name" field
    And I click the submit button
    Then I should be on "choose new delivery partner lead providers" page
    # And the page should be accessible

    When I click on "Lead Provider 1" label
    And I click on "2021" label
    And I click the submit button
    Then I should be on "new delivery partner review" page
    And "main" should contain "New delivery partner"
    And "main" should contain "Lead Provider 1"
    And "main" should contain "2021"
    And the page should be accessible

    When I click the submit button
    Then I should be on "delivery supplier listing" page
    And "main" should contain "New delivery partner"
    And "notification banner" should contain "Delivery partner created"
    And the page should be accessible

  Scenario: It should remember details when navigating backwards in creation process
    When I click on "create delivery partner button"
    And I type "New delivery partner" into "delivery partner name" field
    And I click the submit button
    And I click the back link
    Then "delivery partner name" should have value "New delivery partner"

    When I click the submit button
    And I click on "Lead Provider 1" label
    And I click on "2021" label
    And I click the submit button
    And I click the back link
    Then "Lead Provider 1" label should be checked
    And "2021" label should be checked

  Scenario: It should allow changing name choice during creation
    When I click on "create delivery partner button"
    And I type "wrong name" into "delivery partner name" field
    And I click the submit button
    And I click on "Lead Provider 1" label
    And I click on "2021" label
    And I click the submit button
    And I click on "change name link"
    And I type "{selectall}New delivery partner" into "delivery partner name" field
    And I click the submit button
    And I click the submit button
    Then "main" should contain "New delivery partner"

    When I click the submit button
    Then I should be on "delivery supplier listing" page
    And "main" should contain "New delivery partner"
