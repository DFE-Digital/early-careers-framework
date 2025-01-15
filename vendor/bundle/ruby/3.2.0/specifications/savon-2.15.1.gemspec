# -*- encoding: utf-8 -*-
# stub: savon 2.15.1 ruby lib

Gem::Specification.new do |s|
  s.name = "savon".freeze
  s.version = "2.15.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Harrington".freeze]
  s.date = "2024-07-08"
  s.description = "Heavy metal SOAP client".freeze
  s.email = "me@rubiii.com".freeze
  s.homepage = "http://savonrb.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Heavy metal SOAP client".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<nori>.freeze, ["~> 2.4"])
  s.add_runtime_dependency(%q<httpi>.freeze, [">= 4", "< 5"])
  s.add_runtime_dependency(%q<wasabi>.freeze, [">= 3.7", "< 6"])
  s.add_runtime_dependency(%q<akami>.freeze, ["~> 1.2"])
  s.add_runtime_dependency(%q<gyoku>.freeze, ["~> 1.2"])
  s.add_runtime_dependency(%q<builder>.freeze, [">= 2.1.2"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.8.1"])
  s.add_runtime_dependency(%q<mail>.freeze, ["~> 2.5"])
  s.add_development_dependency(%q<rack>.freeze, ["< 4"])
  s.add_development_dependency(%q<puma>.freeze, [">= 4.3.8", "< 7"])
  s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.3.3"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9"])
  s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14"])
  s.add_development_dependency(%q<json>.freeze, [">= 2.3.0"])
end
