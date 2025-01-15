# -*- encoding: utf-8 -*-
# stub: site_prism-all_there 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "site_prism-all_there".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/site-prism/site_prism-all_there/issues", "changelog_uri" => "https://github.com/site-prism/site_prism-all_there/blob/master/CHANGELOG.md", "source_code_uri" => "https://github.com/site-prism/site_prism-all_there" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luke Hill".freeze]
  s.date = "2019-12-16"
  s.description = "SitePrism AllThere gives you a simple DSL in order to recursively query,\npage/section/element structures on your page - exclusively for use with the SitePrism gem.".freeze
  s.email = ["lukehill_uk@hotmail.com".freeze]
  s.homepage = "https://github.com/site-prism/site_prism-all_there".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "An extension to allow you to recurse through your SitePrism Pages/Sections".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 12.3"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.75.0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.4"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 1.33"])
  s.add_development_dependency(%q<site_prism>.freeze, ["~> 3.2"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
end
