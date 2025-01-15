# -*- encoding: utf-8 -*-
# stub: mail-notify 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mail-notify".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stuart Harrison".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-10-25"
  s.email = ["pezholio@gmail.com".freeze]
  s.homepage = "https://github.com/dxw/mail-notify".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.8".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "ActionMailer support for the GOV.UK Notify API".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8.22"])
  s.add_development_dependency(%q<pry>.freeze, ["~> 0.14.1"])
  s.add_development_dependency(%q<rails>.freeze, ["~> 7"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.6"])
  s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 5.1"])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1"])
  s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.6.2"])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.16.0"])
  s.add_development_dependency(%q<rspec-mocks>.freeze, ["~> 3.11.0"])
  s.add_runtime_dependency(%q<actionmailer>.freeze, [">= 5.2.4.6"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.2.4.6"])
  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 5.2.7.1"])
  s.add_runtime_dependency(%q<actionview>.freeze, [">= 5.2.7.1"])
  s.add_runtime_dependency(%q<notifications-ruby-client>.freeze, ["~> 5.1"])
  s.add_runtime_dependency(%q<rack>.freeze, [">= 2.1.4.1"])
end
