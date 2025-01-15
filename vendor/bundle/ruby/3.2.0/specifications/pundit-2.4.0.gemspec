# -*- encoding: utf-8 -*-
# stub: pundit 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pundit".freeze
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jonas Nicklas".freeze, "Varvet AB".freeze]
  s.date = "2024-08-26"
  s.description = "Object oriented authorization for Rails applications".freeze
  s.email = ["jonas.nicklas@gmail.com".freeze, "info@varvet.com".freeze]
  s.homepage = "https://github.com/varvet/pundit".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "OO authorization for Rails".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
  s.add_development_dependency(%q<actionpack>.freeze, [">= 3.0.0"])
  s.add_development_dependency(%q<activemodel>.freeze, [">= 3.0.0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<railties>.freeze, [">= 3.0.0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.0.0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0.17.0"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
end
