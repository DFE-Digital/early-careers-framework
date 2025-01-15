# -*- encoding: utf-8 -*-
# stub: govuk-components 5.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "govuk-components".freeze
  s.version = "5.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["DfE developers".freeze]
  s.date = "2025-01-12"
  s.description = "This library provides view components for the GOV.UK Design System. It makes creating services more familiar for Ruby on Rails developers.".freeze
  s.email = ["peter.yates@digital.education.gov.uk".freeze]
  s.homepage = "https://github.com/x-govuk/govuk-components".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "GOV.UK Components for Ruby on Rails".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<html-attributes-utils>.freeze, ["~> 1.0.0", ">= 1.0.0"])
  s.add_runtime_dependency(%q<pagy>.freeze, [">= 6", "< 10"])
  s.add_runtime_dependency(%q<view_component>.freeze, [">= 3.18", "< 3.22"])
  s.add_development_dependency(%q<deep_merge>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec-html-matchers>.freeze, ["~> 0.9"])
  s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-govuk>.freeze, ["= 5.0.7"])
  s.add_development_dependency(%q<sassc-rails>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.20"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  s.add_development_dependency(%q<htmlbeautifier>.freeze, ["~> 1.4.1"])
  s.add_development_dependency(%q<nanoc>.freeze, ["~> 4.11"])
  s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3.6.0"])
  s.add_development_dependency(%q<rouge>.freeze, ["~> 4.5.1"])
  s.add_development_dependency(%q<rubypants>.freeze, ["~> 0.7.0"])
  s.add_development_dependency(%q<sass>.freeze, [">= 0"])
  s.add_development_dependency(%q<sassc>.freeze, ["~> 2.4.0"])
  s.add_development_dependency(%q<slim>.freeze, ["~> 5.2.0"])
  s.add_development_dependency(%q<slim_lint>.freeze, ["~> 0.31.0"])
  s.add_development_dependency(%q<webrick>.freeze, ["~> 1.9.0"])
end
