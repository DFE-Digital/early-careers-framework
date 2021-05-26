@ecf
Feature: ECF payment calculation engine

  Scenario: Service fees example 1
    Given the set_up fee is £150,000
      And the recruitment target is 2000
      And Band A per-participant price is £995
     When I run the calculation
     Then the per-participant service fee should be £323
      And the total service fee should be £646,000
      And the monthly service fee should be £22,276

  Scenario: Service fees example 2
    Given the set_up fee is £150,000
      And the recruitment target is 2000
      And Band A per-participant price is £1,350
     When I run the calculation
     Then the per-participant service fee should be £465
      And the total service fee should be £930,000
      And the monthly service fee should be £32,069
