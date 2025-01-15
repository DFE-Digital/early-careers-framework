# HTML Attributes Utilities

[![Tests](https://github.com/DFE-Digital/html-attributes-utils/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/DFE-Digital/html-attributes-utils/actions/workflows/tests.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/da15b0accce3baf10c34/maintainability)](https://codeclimate.com/github/DFE-Digital/html-attributes-utils/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/da15b0accce3baf10c34/test_coverage)](https://codeclimate.com/github/DFE-Digital/html-attributes-utils/test_coverage)
![GitHub](https://img.shields.io/github/license/dfe-digital/html-attributes-utils)
![Supported ruby versions](https://img.shields.io/badge/ruby-%3E%3D%202.7.6-red)
![Supported rails versions](https://img.shields.io/badge/rails-%3E%3D%206.1.6-red)


This is a small library intended to make it easier to deal with HTML
attributes. It was written to reduce overlap in the
[govuk-components](https://github.com/DFE-Digital/govuk-components) and
[govuk-formbuilder](https://github.com/DFE-Digital/govuk-formbuilder) libraries.

It provides refinements for `Hash` that allow:

* deep merging while protecting default values from being overwritten
* tidying hashes by removing key/value pairs that have empty or nil values

## Example use

```ruby
require "html_attributes_utils"

def MyPresenter
  using HTMLAttributesUtils

  def initialize(custom_attributes = {})
    @custom_attributes = custom_attributes
  end

  def attributes
    default_attributes
      .deep_merge_html_attributes(@custom_attributes)
      .deep_tidy_html_attributes
  end

private

  def default_attributes
    { lang: "en-GB", class: "govuk-juggling-widget" }
  end
end

MyPresenter.new(lang: "fr", class: "stripes", some_other_attr: "").attributes

=> { lang: "fr", class: ["govuk-juggling-widget", "stripes"] }
```
