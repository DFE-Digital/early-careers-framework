# -*- encoding: utf-8 -*-
# stub: view_component 3.21.0 ruby lib

Gem::Specification.new do |s|
  s.name = "view_component".freeze
  s.version = "3.21.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/ViewComponent/view_component/blob/main/docs/CHANGELOG.md", "source_code_uri" => "https://github.com/viewcomponent/view_component" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["ViewComponent Team".freeze]
  s.date = "2024-12-19"
  s.homepage = "https://viewcomponent.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A framework for building reusable, testable & encapsulated view components in Ruby on Rails.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.2.0", "< 8.1"])
  s.add_runtime_dependency(%q<method_source>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<allocation_stats>.freeze, ["~> 0.1.5"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.4"])
  s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.13.0"])
  s.add_development_dependency(%q<better_html>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2"])
  s.add_development_dependency(%q<capybara>.freeze, ["~> 3"])
  s.add_development_dependency(%q<cuprite>.freeze, ["~> 0.15"])
  s.add_development_dependency(%q<debug>.freeze, [">= 0"])
  s.add_development_dependency(%q<erb_lint>.freeze, [">= 0"])
  s.add_development_dependency(%q<haml>.freeze, ["~> 6"])
  s.add_development_dependency(%q<jbuilder>.freeze, ["~> 2"])
  s.add_development_dependency(%q<m>.freeze, ["~> 1"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.18"])
  s.add_development_dependency(%q<pry>.freeze, ["~> 0.13"])
  s.add_development_dependency(%q<puma>.freeze, ["~> 6"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 5"])
  s.add_development_dependency(%q<rubocop-md>.freeze, ["~> 1"])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, ["= 4.9.0"])
  s.add_development_dependency(%q<sprockets-rails>.freeze, ["~> 3.4.2"])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.22.0"])
  s.add_development_dependency(%q<simplecov-console>.freeze, ["~> 0.9.1"])
  s.add_development_dependency(%q<slim>.freeze, ["~> 5.1"])
  s.add_development_dependency(%q<turbo-rails>.freeze, ["~> 1"])
  s.add_development_dependency(%q<warning>.freeze, [">= 0"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.34"])
  s.add_development_dependency(%q<yard-activesupport-concern>.freeze, ["~> 0.0.1"])
  s.add_development_dependency(%q<net-imap>.freeze, [">= 0"])
  s.add_development_dependency(%q<net-pop>.freeze, [">= 0"])
  s.add_development_dependency(%q<net-smtp>.freeze, [">= 0"])
  s.add_development_dependency(%q<base64>.freeze, [">= 0"])
  s.add_development_dependency(%q<bigdecimal>.freeze, [">= 0"])
  s.add_development_dependency(%q<drb>.freeze, [">= 0"])
  s.add_development_dependency(%q<mutex_m>.freeze, [">= 0"])
end
