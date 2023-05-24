Feature: Lead Providers Partnership Management
  Scenario: Visiting the Lead Providers landing page
    Given I am on "the Lead Provider landing page" page
    Then the page should be accessible

  Scenario: Learning how to manage partnerships
    Given I am on "the Lead Provider landing page" page
    When I click on "link" containing "How to manage ECF partnerships"
    Then I should be on "Partnership guidance" page
    And the page should be accessible
