## 1.3.3 (2024-02-13)

* Explicitly declare base64 dep in gemfile (useful for testing against ruby-head).

## 1.3.2 (2024-01-09)

* Stop patching Hash [#35](https://github.com/savonrb/akami/pull/35)
* Drop support for ruby 2.7 and below
* GOST engine for openssl is no longer officially supported

## 1.3.1 (2015-05-4)

* Fix regression caused by pull request #20. Object#present? is not available outside of Rails.

## 1.3.0 (2015-03-31)

* Formally drop support for ruby 1.8.7
* Feature: [#20](https://github.com/savonrb/akami/pull/20) Allow passing cert and private keys as a string, rather than a path to a file.

## 1.2.1 (2014-01-31)
* Fix: [#2](https://github.com/savonrb/akami/pull/2) Fixes related to WS-Security,
  UserToken authentication.

## 1.2.0 (2012-06-28)

* Fix: Lowered the version of Nokogiri required to use Akami.

## 1.1.0 (2012-06-06)

* Feature: [#3](https://github.com/savonrb/akami/pull/3) - WSSE signing.

## 1.0.0 (2011-07-03)

* Initial version extracted from the [Savon](http://rubygems.org/gems/savon) library.
