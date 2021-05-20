@ecf
Feature: ECF payment calculation engine

  Scenario: Service fees example 1
    Given the recruitment target is 2000
      And Band A per-participant price is £995
    When I run the calculation
    Then the per-participant service fee should be £398
      And the total service fee should be £796,000
      And the monthly service fee should be £27,448

  Scenario: Service fees example 2
    Given the recruitment target is 2000
    And Band A per-participant price is £1,350
    When I run the calculation
    Then the per-participant service fee should be £540
    And the total service fee should be £1,080,000
    And the monthly service fee should be £37,241
