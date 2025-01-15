# -*- encoding: utf-8 -*-
# stub: activerecord-explain-analyze 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "activerecord-explain-analyze".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Peter Graham".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-10-27"
  s.description = "Extends ActiveRecord#explain with support for EXPLAIN ANALYZE and output formats of JSON, XML, and YAML.".freeze
  s.email = ["peterghm@gmail.com".freeze]
  s.homepage = "https://github.com/6/activerecord-explain-analyze".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "ActiveRecord#explain with support for EXPLAIN ANALYZE and a variety of output formats".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4"])
  s.add_runtime_dependency(%q<pg>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.15"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec-collection_matchers>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler-audit>.freeze, [">= 0"])
end
