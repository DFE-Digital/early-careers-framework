# -*- encoding: utf-8 -*-
# stub: canonical-rails 0.2.16 ruby lib

Gem::Specification.new do |s|
  s.name = "canonical-rails".freeze
  s.version = "0.2.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Denis Ivanov".freeze]
  s.date = "2024-10-23"
  s.description = "Configurable, but assumes a conservative strategy by default with a goal to solve many search engine index problems: multiple hostnames, inbound links with arbitrary parameters, trailing slashes. ".freeze
  s.email = ["visible@jumph4x.net".freeze]
  s.homepage = "https://github.com/jumph4x/canonical-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Simple and configurable Rails canonical ref tag helper".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionview>.freeze, [">= 4.1", "< 7.3"])
  s.add_development_dependency(%q<actionpack>.freeze, [">= 4.1", "< 7.3"])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 4.0.1"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
end
