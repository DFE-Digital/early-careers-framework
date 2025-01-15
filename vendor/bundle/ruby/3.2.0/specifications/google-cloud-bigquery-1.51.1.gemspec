# -*- encoding: utf-8 -*-
# stub: google-cloud-bigquery 1.51.1 ruby lib

Gem::Specification.new do |s|
  s.name = "google-cloud-bigquery".freeze
  s.version = "1.51.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Moore".freeze, "Chris Smith".freeze]
  s.date = "2024-12-13"
  s.description = "google-cloud-bigquery is the official library for Google BigQuery.".freeze
  s.email = ["mike@blowmage.com".freeze, "quartzmo@gmail.com".freeze]
  s.homepage = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-bigquery".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "API Client library for Google BigQuery".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<bigdecimal>.freeze, ["~> 3.0"])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<google-apis-bigquery_v2>.freeze, ["~> 0.71"])
  s.add_runtime_dependency(%q<google-apis-core>.freeze, ["~> 0.13"])
  s.add_runtime_dependency(%q<googleauth>.freeze, ["~> 1.9"])
  s.add_runtime_dependency(%q<google-cloud-core>.freeze, ["~> 1.6"])
  s.add_runtime_dependency(%q<mini_mime>.freeze, ["~> 1.0"])
end
