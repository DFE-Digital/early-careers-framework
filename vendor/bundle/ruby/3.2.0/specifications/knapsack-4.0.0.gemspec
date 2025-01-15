# -*- encoding: utf-8 -*-
# stub: knapsack 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "knapsack".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["ArturT".freeze]
  s.date = "2021-08-05"
  s.description = "Parallel tests across CI server nodes based on each test file's time execution. It generates a test time execution report and uses it for future test runs.".freeze
  s.email = ["arturtrzop@gmail.com".freeze]
  s.executables = ["knapsack".freeze]
  s.files = ["bin/knapsack".freeze]
  s.homepage = "https://github.com/KnapsackPro/knapsack".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Knapsack splits tests across CI nodes and makes sure that tests will run comparable time on each node.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 1.6"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<rspec-its>.freeze, ["~> 1.3"])
  s.add_development_dependency(%q<cucumber>.freeze, [">= 0"])
  s.add_development_dependency(%q<spinach>.freeze, [">= 0.8"])
  s.add_development_dependency(%q<minitest>.freeze, [">= 5.0.0"])
  s.add_development_dependency(%q<pry>.freeze, ["~> 0"])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0.9.4"])
end
