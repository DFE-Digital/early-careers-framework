@ecf
Feature: ECF contract calculations

  Scenario: Setup fees
    Given the set_up fee is £150,000
    And the recruitment target is 2000
    And Band A per-participant price is £1,400
    When I setup the contract
    Then the per-participant service fee should be reduced to £485
    And the output payment per-participant should be unchanged at £840

