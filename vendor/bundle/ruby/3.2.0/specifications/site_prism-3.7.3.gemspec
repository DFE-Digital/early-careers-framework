# -*- encoding: utf-8 -*-
# stub: site_prism 3.7.3 ruby lib

Gem::Specification.new do |s|
  s.name = "site_prism".freeze
  s.version = "3.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/site-prism/site_prism/issues", "changelog_uri" => "https://github.com/site-prism/site_prism/blob/main/CHANGELOG.md", "source_code_uri" => "https://github.com/site-prism/site_prism" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luke Hill".freeze, "Nat Ritmeyer".freeze]
  s.date = "2021-09-20"
  s.description = "SitePrism gives you a simple, clean and semantic DSL for describing your site. SitePrism implements the Page Object Model pattern on top of Capybara.".freeze
  s.email = ["lukehill_uk@hotmail.com".freeze, "nat@natontesting.com".freeze]
  s.homepage = "https://github.com/site-prism/site_prism".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A Page Object Model DSL for Capybara".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.6"])
  s.add_runtime_dependency(%q<capybara>.freeze, ["~> 3.15"])
  s.add_runtime_dependency(%q<site_prism-all_there>.freeze, [">= 0.3.1", "< 1.0"])
  s.add_development_dependency(%q<cucumber>.freeze, ["> 4", "< 8"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.10"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.11.0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.10.1"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2.2.0"])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, [">= 3.13", "< 4.1"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  s.add_development_dependency(%q<webdrivers>.freeze, ["~> 4.6"])
end
