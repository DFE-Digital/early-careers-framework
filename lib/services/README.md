# cpd-payment-calculations
Draft payment calculations engine

## About

This engine performs all payment calculations for both [ECFs (Early Career Framework)](https://www.early-career-framework.education.gov.uk/) and [the reformed NPQs (National Professional Qualification)](https://www.gov.uk/government/publications/national-professional-qualifications-frameworks-from-september-2021) so that training providers can be paid the correct amount.

It is publicly accessible code which means the providers and any other interested parties are be able to satisfy themselves that the numbers they receive match the rules defined herein.

The calculations are defined first in BDD feature files that can be validated by interested parties, then these in turn validate that the calculation engine is producing the expected numbers.

The output of the engine includes the result of each intermediary step in the calculation so that any questions over how the final totals were reached can be answered by interested parties.

## Calculation definitions

The definitions of the calculations and the example calculations being tested can be found in [spec/features](spec/features). These are intended to be readable and editable by non-developers.

## Development

Support for Gherkin syntax rspec tests is provided by [turnip](https://github.com/jnicklas/turnip).

[Guard](https://github.com/guard/guard) is configured to automatically run tests. Start guard with `bundle exec guard`.

## Architecture Decision Records

* There is a cross-project ADR at <https://github.com/DFE-Digital/cpd-adr>
* This project's ADR is in [documentation/adr/](documentation/adr/)

### Naming

Here are the names we are using in the code and specs for the different concepts involved in the calculations by way of an example:

> Per participant price £995 >>
per participant service fee £398 (40%) >> monthly service fee £27k >> total service fee £796k
>
> Per participant price £995 >> per participant output payment £597 (60%) >> per participant output payment for a retention period £119 (20% of 60%) >> output payment subtotal for a retention period with 1900 retained participants £226k

* "Participants" includes both teachers and mentors.
* "Output payments" are payments made based on the performance of the training provider (i.e. their output). Previously known as "variable payments" in the code.
* "Payment type" for start/retention/completion output payments.
