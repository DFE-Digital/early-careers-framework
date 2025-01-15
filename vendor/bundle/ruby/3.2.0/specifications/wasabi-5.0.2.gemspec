# -*- encoding: utf-8 -*-
# stub: wasabi 5.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "wasabi".freeze
  s.version = "5.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/savonrb/wasabi/issues", "changelog_uri" => "https://github.com/savonrb/wasabi/blob/master/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/wasabi/5.0.2", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/savonrb/wasabi" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Harrington".freeze]
  s.date = "2024-02-27"
  s.description = "A simple WSDL parser".freeze
  s.email = ["me@rubiii.com".freeze]
  s.homepage = "https://github.com/savonrb/wasabi".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A simple WSDL parser".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<faraday>.freeze, ["~> 2.8"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.13.9"])
  s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
end
