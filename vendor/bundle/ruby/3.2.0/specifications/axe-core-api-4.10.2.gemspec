# -*- encoding: utf-8 -*-
# stub: axe-core-api 4.10.2 ruby lib

Gem::Specification.new do |s|
  s.name = "axe-core-api".freeze
  s.version = "4.10.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/dequelabs/axe-core-gems/issues", "homepage_uri" => "https://www.deque.com", "source_code_uri" => "https://github.com/dequelabs/axe-core-gems" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Deque Systems".freeze]
  s.date = "2024-11-08"
  s.email = ["helpdesk@deque.com".freeze]
  s.homepage = "https://www.deque.com".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Axe API utility methods".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<dumb_delegator>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<ostruct>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<virtus>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.1"])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0"])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
  s.add_development_dependency(%q<watir>.freeze, [">= 0"])
end
