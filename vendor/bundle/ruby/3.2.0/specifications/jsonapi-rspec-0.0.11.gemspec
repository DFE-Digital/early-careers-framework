# -*- encoding: utf-8 -*-
# stub: jsonapi-rspec 0.0.11 ruby lib

Gem::Specification.new do |s|
  s.name = "jsonapi-rspec".freeze
  s.version = "0.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lucas Hosseini".freeze]
  s.date = "2020-12-19"
  s.description = "Helpers for validating JSON API payloads".freeze
  s.email = ["lucas.hosseini@gmail.com".freeze]
  s.homepage = "https://github.com/jsonapi-rb/jsonapi-rspec".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "RSpec matchers for JSON API.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rspec-core>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rspec-expectations>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
end
