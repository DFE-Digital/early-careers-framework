@npq
Feature: NPQ single-qualification payment schedule calculation

  Scenario: Calculation of NPQLTD payment schedules with one retention point
    Given there's a qualification with a per-participant price of £902
      And there are 19 monthly service fee payments
      And the recruitment target is 1000
      And there are the following retention points:
        | Payment Type | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Commencement | 1000                  | £180.40                                 | £180,400.00                      |
        | Retention 1  | 700                   | £180.40                                 | £126,280.00                      |
        | Completion   | 300                   | £180.40                                 | £54,120.00                       |
    Then expected output payments should be as above
      And the service fee payment schedule should be:
        | Month | Service Fee |
        | 1     | £18,989.54  |
        | 2     | £18,989.47  |
        | 3     | £18,989.47  |
        | 4     | £18,989.47  |
        | 5     | £18,989.47  |
        | 6     | £18,989.47  |
        | 7     | £18,989.47  |
        | 8     | £18,989.47  |
        | 9     | £18,989.47  |
        | 10    | £18,989.47  |
        | 11    | £18,989.47  |
        | 12    | £18,989.47  |
        | 13    | £18,989.47  |
        | 14    | £18,989.47  |
        | 15    | £18,989.47  |
        | 16    | £18,989.47  |
        | 17    | £18,989.47  |
        | 18    | £18,989.47  |
        | 19    | £18,989.47  |
      And the service fee total should be £360,800.00
      And the service fee schedule total should be the same as the service fee total

  Scenario: Calculation of NPQSL payment schedules with two retention points
    Given there's a qualification with a per-participant price of £1149
      And there are 25 monthly service fee payments
      And the recruitment target is 1000
      And there are the following retention points:
        | Payment Type | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Commencement | 900                   | £172.35                                 | £155,115.00                      |
        | Retention 1  | 700                   | £172.35                                 | £120,645.00                      |
        | Retention 2  | 650                   | £172.35                                 | £112,027.50                      |
        | Completion   | 432                   | £172.35                                 | £74,455.20                       |
    Then expected output payments should be as above
      And the service fee payment schedule should be:
        | Month | Service Fee |
        | 1     | £18,384.00  |
        | 2     | £18,384.00  |
        | 3     | £18,384.00  |
        | 4     | £18,384.00  |
        | 5     | £18,384.00  |
        | 6     | £18,384.00  |
        | 7     | £18,384.00  |
        | 8     | £18,384.00  |
        | 9     | £18,384.00  |
        | 10    | £18,384.00  |
        | 11    | £18,384.00  |
        | 12    | £18,384.00  |
        | 13    | £18,384.00  |
        | 14    | £18,384.00  |
        | 15    | £18,384.00  |
        | 16    | £18,384.00  |
        | 17    | £18,384.00  |
        | 18    | £18,384.00  |
        | 19    | £18,384.00  |
        | 20    | £18,384.00  |
        | 21    | £18,384.00  |
        | 22    | £18,384.00  |
        | 23    | £18,384.00  |
        | 24    | £18,384.00  |
        | 25    | £18,384.00  |
      And the service fee total should be £459,600.00
      And the service fee schedule total should be the same as the service fee total

  Scenario: Calculation of NPQLH payment schedules with two retention points
    Given there's a qualification with a per-participant price of £1985
      And there are 31 monthly service fee payments
      And the recruitment target is 1000
      And there are the following retention points:
        | Payment Type | Retained Participants | Expected Per-Participant Output Payment | Expected Output Payment Subtotal |
        | Commencement | 900                   | £297.75                                 | £267,975.00                      |
        | Retention 1  | 700                   | £297.75                                 | £208,425.00                      |
        | Retention 2  | 650                   | £297.75                                 | £193,537.50                      |
        | Completion   | 432                   | £297.75                                 | £128,628.00                      |
    Then expected output payments should be as above
      And the service fee payment schedule should be:
        | Month | Service Fee |
        | 1     | £25,613.00  |
        | 2     | £25,612.90  |
        | 3     | £25,612.90  |
        | 4     | £25,612.90  |
        | 5     | £25,612.90  |
        | 6     | £25,612.90  |
        | 7     | £25,612.90  |
        | 8     | £25,612.90  |
        | 9     | £25,612.90  |
        | 10    | £25,612.90  |
        | 11    | £25,612.90  |
        | 12    | £25,612.90  |
        | 13    | £25,612.90  |
        | 14    | £25,612.90  |
        | 15    | £25,612.90  |
        | 16    | £25,612.90  |
        | 17    | £25,612.90  |
        | 18    | £25,612.90  |
        | 19    | £25,612.90  |
        | 20    | £25,612.90  |
        | 21    | £25,612.90  |
        | 22    | £25,612.90  |
        | 23    | £25,612.90  |
        | 24    | £25,612.90  |
        | 25    | £25,612.90  |
        | 26    | £25,612.90  |
        | 27    | £25,612.90  |
        | 28    | £25,612.90  |
        | 29    | £25,612.90  |
        | 30    | £25,612.90  |
        | 31    | £25,612.90  |
      And the service fee total should be £794,000.00
      And the service fee schedule total should be the same as the service fee total
