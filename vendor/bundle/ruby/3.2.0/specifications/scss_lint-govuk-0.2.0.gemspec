# -*- encoding: utf-8 -*-
# stub: scss_lint-govuk 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "scss_lint-govuk".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Government Digital Service".freeze]
  s.date = "2019-11-06"
  s.description = "Shared scss-lint rules for SASS projects in GOV.UK".freeze
  s.email = ["govuk-dev@digital.cabinet-office.gov.uk".freeze]
  s.homepage = "https://github.com/alphagov/scss-lint-govuk".freeze
  s.rubygems_version = "3.4.19".freeze
  s.summary = "scss-lint GOV.UK plugin".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-govuk>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<scss_lint>.freeze, [">= 0"])
end
