# -*- encoding: utf-8 -*-
# stub: zendesk_api 3.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "zendesk_api".freeze
  s.version = "3.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/zendesk/zendesk_api_client_rb/issues", "changelog_uri" => "https://github.com/zendesk/zendesk_api_client_rb/blob/v3.1.1/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/zendesk_api/3.1.1", "source_code_uri" => "https://github.com/zendesk/zendesk_api_client_rb/tree/v3.1.1", "wiki_uri" => "https://github.com/zendesk/zendesk_api_client_rb/wiki" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Steven Davidovitz".freeze, "Michael Grosser".freeze]
  s.date = "2024-09-04"
  s.description = "Ruby wrapper for the REST API at https://www.zendesk.com. Documentation at https://developer.zendesk.com.".freeze
  s.email = ["support@zendesk.com".freeze]
  s.homepage = "https://developer.zendesk.com".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Zendesk REST API Client".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<faraday>.freeze, ["> 2.0.0"])
  s.add_runtime_dependency(%q<faraday-multipart>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<hashie>.freeze, [">= 3.5.2", "< 6.0.0"])
  s.add_runtime_dependency(%q<inflection>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<multipart-post>.freeze, ["~> 2.0"])
  s.add_runtime_dependency(%q<mini_mime>.freeze, [">= 0"])
end
