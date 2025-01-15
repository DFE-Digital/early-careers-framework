# -*- encoding: utf-8 -*-
# stub: scenic 1.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "scenic".freeze
  s.version = "1.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Derek Prior".freeze, "Caleb Hearth".freeze]
  s.date = "2024-03-28"
  s.description = "    Adds methods to ActiveRecord::Migration to create and manage database views\n    in Rails\n".freeze
  s.email = ["derekprior@gmail.com".freeze, "caleb@calebhearth.com".freeze]
  s.homepage = "https://github.com/scenic-views/scenic".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Support for database views in Rails migrations".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, [">= 1.5"])
  s.add_development_dependency(%q<database_cleaner>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.3"])
  s.add_development_dependency(%q<pg>.freeze, ["~> 0.19"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<ammeter>.freeze, [">= 1.1.3"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  s.add_development_dependency(%q<redcarpet>.freeze, [">= 0"])
  s.add_development_dependency(%q<standard>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.0.0"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 4.0.0"])
end
