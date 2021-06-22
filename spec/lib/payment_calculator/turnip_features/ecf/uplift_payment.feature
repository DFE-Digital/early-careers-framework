@ecf
Feature: ECF contract calculations

  Scenario: Uplift payment
    Given An uplift per participant of £100
    And there are 100 sparsity and 200 pupil premium participants who have started that are eligible for the uplift payment
    When I setup the contract with uplift payment
    Then the total uplift payment should be £30,000
