# -*- encoding: utf-8 -*-
# stub: akami 1.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "akami".freeze
  s.version = "1.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Harrington".freeze]
  s.date = "2024-02-13"
  s.description = "Building Web Service Security".freeze
  s.email = ["me@rubiii.com".freeze]
  s.homepage = "https://github.com/savonrb/akami".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Web Service Security".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<gyoku>.freeze, [">= 0.4.0"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<base64>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.12"])
  s.add_development_dependency(%q<timecop>.freeze, ["~> 0.5"])
end
