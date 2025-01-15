# scss-lint GOV.UK

This repository provides common [scss-lint][scss-lint] rules for use with GOV.UK SCSS projects to comply with our [style guides][guides].

## Installation

Add `scss_lint-govuk` to your Gemfile and then run `bundle install`:

```ruby
# Gemfile
gem 'scss_lint-govuk'
```

Add the plugin to your project's scss-lint config:

```yaml
# .scss-lint.yml
plugin_gems: ['scss_lint-govuk']
```

## Usage

Run scss-lint:

```sh
bundle exec scss-lint
```

[guides]: https://github.com/alphagov/styleguides
[scss-lint]: https://github.com/brigade/scss-lint
