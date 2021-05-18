# 2. Use BigDecimal for currency storage

Date: 2021-03-23

## Status

Accepted

## Context

A common pitfall in choice of data storage for currency for money is to use floating point which then results in rounding errors due to the inexact representation of base-10 (decimal) fractional numbers in base-2 (binary) floating point storage that can result in a loss of faith in a calculations system.

Options available:

1. [BigDecimal](https://ruby-doc.org/stdlib-3.0.0/libdoc/bigdecimal/rdoc/BigDecimal.html) as pounds.pence
2. [BigDecimal](https://ruby-doc.org/stdlib-3.0.0/libdoc/bigdecimal/rdoc/BigDecimal.html) as pence
3. The [RubyMoney/Money gem](https://github.com/RubyMoney/money)
4. [float](https://ruby-doc.org/core-3.0.0/Float.html) (default for numbers in ruby)

I'm glad to say rounding errors here are [unlikely to be fatal as has been seen before](https://www.gao.gov/products/imtec-92-26) but we'd still like to avoid them.

### Research

* <https://www.honeybadger.io/blog/ruby-currency/>

## Decision

### 1. BigDecimal as pounds.pence - yes

* Provides accurate rounding compared to float, producing the results that accountants would expect.
* Extra dependency, albeit commonly used.
* No mismatch between normal written representation of the value and the stored value (compared to storing as pence).

BigDecimal provides [`BigDecimal.round`](https://ruby-doc.org/stdlib-3.0.0/libdoc/bigdecimal/rdoc/BigDecimal.html#method-i-round) that we can use to round up to pennies as needed.

### 2. BigDecimal as pence - no

Some developers like to store currency in pennies.

I've not seen a compelling reason to do this. I personally think it adds extra risk of confusion compared to using the decimal type in a way that matches the currency (i.e. pounds as the integer part of a decimal and pennies as the fractional part).

* <https://stackoverflow.com/questions/18934774/what-are-the-downsides-to-storing-money-values-as-cents-minor-units>

### 3. RubyMoney - no (for now)

The [RubyMoney/Money gem](https://github.com/RubyMoney/money):

This type provides extra information about the currency in use (e.g. GBP, USD) which is of no use to us as this is an entirely GBP system.

Using a money type would explicitly shows that the numbers stored are financial which would be nice but isn't critical to understanding.

It also provides formatting and truncation methods. We don't yet know if these will prove useful.

It is judged that the tradeoff for introducing an additional relatively complex dependency for the possible benefits is not currently worthwhile.

### 4. Floats - no

Do not use for money. Ever.

Storing currency in floats causes rounding errors so that's out.

## Consequences

> *What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.*

* Floating point cumulative rounding errors eliminated.
* Minimal extra dependencies.
* Possibility of upgrading to RubyMoney should need arise.

## Other considerations

### Rounding approaches

We have not (at time of writing) considered the use (intentionally or otherwise) of "[banker's rounding](https://rounding.to/understanding-the-bankers-rounding/)" and other rounding algorithms.

There's an [interesting discussion that happened when ruby adjusted rounding for floats](https://bugs.ruby-lang.org/issues/12958#note-16).
