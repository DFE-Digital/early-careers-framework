# -*- encoding: utf-8 -*-
# stub: rubocop-govuk 4.18.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-govuk".freeze
  s.version = "4.18.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Government Digital Service".freeze]
  s.date = "2024-06-04"
  s.description = "Shared RuboCop rules for Ruby projects in GOV.UK".freeze
  s.email = ["govuk-dev@digital.cabinet-office.gov.uk".freeze]
  s.homepage = "https://github.com/alphagov/rubocop-govuk".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "RuboCop GOV.UK".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 13"])
  s.add_runtime_dependency(%q<rubocop>.freeze, ["= 1.64.1"])
  s.add_runtime_dependency(%q<rubocop-ast>.freeze, ["= 1.31.3"])
  s.add_runtime_dependency(%q<rubocop-rails>.freeze, ["= 2.25.0"])
  s.add_runtime_dependency(%q<rubocop-rake>.freeze, ["= 0.6.0"])
  s.add_runtime_dependency(%q<rubocop-rspec>.freeze, ["= 2.30.0"])
end
