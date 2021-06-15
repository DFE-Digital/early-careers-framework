@ecf
Feature: ECF payment calculation engine

  Scenario: Output payment example 1
    Given the set_up fee is £150,000
      And the recruitment target is 2000
      And Band A per-participant price is £995
      And there are the following retention numbers:
        | Payment Type | Month    | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Started      | Jan 2021 | 1900                  | £119.00                                 | £226,860                         |
        | Retention 1  | Jun 2021 | 1700                  | £90.00                                  | £152,235                         |
        | Retention 2  | Feb 2022 | 1500                  | £90.00                                  | £134,325                         |
        | Retention 3  | Jul 2022 | 1000                  | £90.00                                  | £89,550                          |
        | Retention 4  | Mar 2023 | 800                   | £90.00                                  | £71,640                          |
        | Completion   | Aug 2023 | 500                   | £119.00                                 | £59,700                          |
    When I run each calculation
    Then the output payment per-participant should be £597
     And the output payment schedule should be as above

  Scenario: Output payment example 2
    Given the set_up fee is £150,000
      And the recruitment target is 2000
      And Band A per-participant price is £1,350
      And there are the following retention numbers:
        | Payment Type | Month    | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Started      | Jan 2021 | 1900                  | £162.00                                 | £307,800                         |
        | Retention 1  | Jun 2021 | 1700                  | £122.00                                 | £206,550                         |
        | Retention 2  | Feb 2022 | 1500                  | £122.00                                 | £182,250                         |
        | Retention 3  | Jul 2022 | 1000                  | £122.00                                 | £121,500                         |
        | Retention 4  | Mar 2023 | 800                   | £122.00                                 | £97,200                          |
        | Completion   | Aug 2023 | 500                   | £162.00                                 | £81,000                          |
    When I run each calculation
    Then the monthly service fee should be £32,069
     And the output payment per-participant should be £810
     And the output payment schedule should be as above
