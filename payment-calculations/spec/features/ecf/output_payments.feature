@ecf
Feature: ECF payment calculation engine

  Scenario: Output payment example 1
    Given the recruitment target is 2000
      And Band A per-participant price is £995
      And there are the following retention numbers:
        | Payment Type | Month    | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Start        | Jan 2021 | 1900                  | £119.40                                 | £226,860                         |
        | Retention 1  | Jun 2021 | 1700                  | £89.55                                  | £152,235                         |
        | Retention 2  | Feb 2022 | 1500                  | £89.55                                  | £134,325                         |
        | Retention 3  | Jul 2022 | 1000                  | £89.55                                  | £89,550                          |
        | Retention 4  | Mar 2023 | 800                   | £89.55                                  | £71,640                          |
        | Completion   | Aug 2023 | 500                   | £119.40                                 | £59,700                          |
    When I run the calculation
    Then the output payment per-participant should be £597
      And the output payment schedule should be as above

  Scenario: Output payment example 2
    Given the recruitment target is 2000
      And Band A per-participant price is £1,350
      And there are the following retention numbers:
        | Payment Type | Month    | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Start        | Jan 2021 | 1900                  | £162.00                                 | £307,800                         |
        | Retention 1  | Jun 2021 | 1700                  | £121.50                                 | £206,550                         |
        | Retention 2  | Feb 2022 | 1500                  | £121.50                                 | £182,250                         |
        | Retention 3  | Jul 2022 | 1000                  | £121.50                                 | £121,500                         |
        | Retention 4  | Mar 2023 | 800                   | £121.50                                 | £97,200                          |
        | Completion   | Aug 2023 | 500                   | £162.00                                 | £81,000                          |
    When I run the calculation
    Then the monthly service fee should be £37,241
      And the output payment per-participant should be £810
      And the output payment schedule should be as above
