# -*- encoding: utf-8 -*-
# stub: openapi3_parser 0.9.2 ruby lib

Gem::Specification.new do |s|
  s.name = "openapi3_parser".freeze
  s.version = "0.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kevin Dew".freeze]
  s.date = "2022-03-21"
  s.description = "    A tool to parse and validate OpenAPI V3 files.\n    Aims to provide complete compatibility with the OpenAPI specification and\n    to provide a natural, idiomatic way to interact with a openapi.yaml file.\n".freeze
  s.email = "kevindew@me.com".freeze
  s.homepage = "https://github.com/kevindew/openapi_parser".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "An OpenAPI V3 parser for Ruby".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<commonmarker>.freeze, ["~> 0.17"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<byebug>.freeze, ["~> 11.0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1"])
  s.add_development_dependency(%q<rubocop-rake>.freeze, ["~> 0.5"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.19"])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.8"])
end
