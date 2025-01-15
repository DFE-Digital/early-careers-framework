# -*- encoding: utf-8 -*-
# stub: html-attributes-utils 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "html-attributes-utils".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/DFE-Digital/html-attributes-utils/issues", "changelog_uri" => "https://github.com/DFE-Digital/html-attributes-utils/releases", "documentation_uri" => "https://www.rubydoc.info/gems/html-attributes-utils/", "github_repo" => "https://github.com/DFE-Digital/html-attributes-utils", "homepage_uri" => "https://govuk-form-builder.netlify.app", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/DFE-Digital/html-attributes-utils" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Peter Yates".freeze]
  s.date = "2023-07-25"
  s.description = "A small collection of utilities to ease working with hashes of HTML attributes".freeze
  s.email = ["peter.yates@graphia.co.uk".freeze]
  s.homepage = "https://github.com/DFE-Digital/html-attributes-utils".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "HTML attribute hash utilities".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 6.1.4.4"])
  s.add_development_dependency(%q<debug>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.11.0"])
  s.add_development_dependency(%q<rubocop-govuk>.freeze, ["~> 4.3.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.20"])
end
