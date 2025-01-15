# -*- encoding: utf-8 -*-
# stub: googleauth 1.12.0 ruby lib

Gem::Specification.new do |s|
  s.name = "googleauth".freeze
  s.version = "1.12.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/googleapis/google-auth-library-ruby/issues", "changelog_uri" => "https://github.com/googleapis/google-auth-library-ruby/blob/main/CHANGELOG.md", "source_code_uri" => "https://github.com/googleapis/google-auth-library-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Emiola".freeze]
  s.date = "2024-12-05"
  s.description = "Implements simple authorization for accessing Google APIs, and provides support for Application Default Credentials.".freeze
  s.email = ["temiola@google.com".freeze]
  s.homepage = "https://github.com/googleapis/google-auth-library-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Google Auth Library for Ruby".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<faraday>.freeze, [">= 1.0", "< 3.a"])
  s.add_runtime_dependency(%q<google-cloud-env>.freeze, ["~> 2.2"])
  s.add_runtime_dependency(%q<google-logging-utils>.freeze, ["~> 0.1"])
  s.add_runtime_dependency(%q<jwt>.freeze, [">= 1.4", "< 3.0"])
  s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.11"])
  s.add_runtime_dependency(%q<os>.freeze, [">= 0.9", "< 2.0"])
  s.add_runtime_dependency(%q<signet>.freeze, [">= 0.16", "< 2.a"])
end
