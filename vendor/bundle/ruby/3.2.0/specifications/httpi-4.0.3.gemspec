# -*- encoding: utf-8 -*-
# stub: httpi 4.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "httpi".freeze
  s.version = "4.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/savonrb/httpi/issues", "changelog_uri" => "https://github.com/savonrb/httpi/blob/master/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/httpi", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/savonrb/httpi", "wiki_uri" => "https://github.com/savonrb/httpi/wiki" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Harrington".freeze, "Martin Tepper".freeze]
  s.date = "2024-07-06"
  s.description = "Common interface for Ruby's HTTP libraries".freeze
  s.email = "me@rubiii.com".freeze
  s.homepage = "https://github.com/savonrb/httpi".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Common interface for Ruby's HTTP libraries".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rack>.freeze, [">= 2.0", "< 4"])
  s.add_runtime_dependency(%q<nkf>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<base64>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<mutex_m>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubyntlm>.freeze, ["~> 0.6.4"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
  s.add_development_dependency(%q<mocha>.freeze, ["~> 0.13"])
  s.add_development_dependency(%q<puma>.freeze, ["~> 6.0"])
  s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
end
