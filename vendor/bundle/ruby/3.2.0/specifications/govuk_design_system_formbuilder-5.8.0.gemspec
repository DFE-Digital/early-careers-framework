# -*- encoding: utf-8 -*-
# stub: govuk_design_system_formbuilder 5.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "govuk_design_system_formbuilder".freeze
  s.version = "5.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/x-govuk/govuk-form-builder/issues", "changelog_uri" => "https://github.com/x-govuk/govuk-form-builder/releases", "documentation_uri" => "https://www.rubydoc.info/gems/govuk_design_system_formbuilder/GOVUKDesignSystemFormBuilder/Builder", "github_repo" => "https://github.com/x-govuk/govuk-form-builder", "homepage_uri" => "https://govuk-form-builder.netlify.app", "source_code_uri" => "https://github.com/x-govuk/govuk-form-builder" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Peter Yates".freeze]
  s.date = "2025-01-12"
  s.description = "This library provides view components for the GOV.UK Design System. It makes creating services more familiar for Ruby on Rails developers.".freeze
  s.email = ["peter.yates@graphia.co.uk".freeze]
  s.homepage = "https://govuk-form-builder.netlify.app".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "GOV.UK Form Builder for Ryby on Rails".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<html-attributes-utils>.freeze, ["~> 1"])
  s.add_runtime_dependency(%q<actionview>.freeze, [">= 6.1"])
  s.add_runtime_dependency(%q<activemodel>.freeze, [">= 6.1"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 6.1"])
  s.add_development_dependency(%q<ostruct>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry>.freeze, ["~> 0.14.1"])
  s.add_development_dependency(%q<pry-byebug>.freeze, ["~> 3.9", ">= 3.9.0"])
  s.add_development_dependency(%q<rspec-html-matchers>.freeze, ["~> 0"])
  s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 6.0"])
  s.add_development_dependency(%q<rubocop-govuk>.freeze, ["~> 5.0.1"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.20"])
  s.add_development_dependency(%q<htmlbeautifier>.freeze, ["~> 1.4.1"])
  s.add_development_dependency(%q<nanoc>.freeze, ["~> 4.13.0"])
  s.add_development_dependency(%q<rouge>.freeze, ["~> 4.5.1"])
  s.add_development_dependency(%q<rubypants>.freeze, ["~> 0.7.0"])
  s.add_development_dependency(%q<sass>.freeze, [">= 0"])
  s.add_development_dependency(%q<sassc>.freeze, ["~> 2.4.0"])
  s.add_development_dependency(%q<slim>.freeze, ["~> 5.2.0"])
  s.add_development_dependency(%q<slim_lint>.freeze, ["~> 0.31.0"])
  s.add_development_dependency(%q<webrick>.freeze, ["~> 1.9.1"])
  s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3.6.0"])
end
