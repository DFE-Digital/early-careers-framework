# -*- encoding: utf-8 -*-
# stub: pretender 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pretender".freeze
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew Kane".freeze]
  s.date = "2023-07-02"
  s.email = "andrew@ankane.org".freeze
  s.homepage = "https://github.com/ankane/pretender".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Log in as another user in Rails".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 6.1"])
end
