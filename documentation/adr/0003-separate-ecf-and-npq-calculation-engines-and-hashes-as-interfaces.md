# 3. Separate ECF and NPQ calculation engines and using hashes for input/output interfaces

Date: 2021-03-30

## Status

Accepted

## Context

There are currently two different training schemes in scope for the track-and-pay project. There are rumours of a possible third in the future.

There are some similarities and many differences in the inputs, outputs and maths for payments for these training schemes. For example:

1. Both have fixed payments at 40%
2. Both allow pulling some of the fixed payment into earlier "setup" payments (for cashflow).
3. The output payments are very different in detail.
4. They have different banding systems.

### People

Tim Abell and Pavel Lisovin (track and pay developers) discussed the issue amongst ourselves and came to this as a decision for the time being.

## Decision

1. Build two payment engines that do not share code.
2. Have similar input/output interfaces (ruby hash structures) that can later be easily converted to JSON.
3. Use similar patterns for both engines of Gherkin BDD driven unit tests plus normal rspec unit tests.

## Consequences

> *What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.*

1. Keeping them separate this will allow us to iterate fast even if the payment calculation rules diversify, making sure we don't put engineering-driven constraints on policy decisions about each training scheme's payment systems.
2. Having a consistent input/output interface should allow us to integrate both engines into whatever larger flow they end up in.
