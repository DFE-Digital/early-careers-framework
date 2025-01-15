# -*- encoding: utf-8 -*-
# stub: notifications-ruby-client 5.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "notifications-ruby-client".freeze
  s.version = "5.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Government Digital Service".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-10-06"
  s.email = ["notify@digital.cabinet-office.gov.uk".freeze]
  s.homepage = "https://github.com/alphagov/notifications-ruby-client".freeze
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Ruby client for GOV.UK Notifications API".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<jwt>.freeze, [">= 1.5", "< 3"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.4"])
  s.add_development_dependency(%q<factory_bot>.freeze, ["~> 6.1"])
end
