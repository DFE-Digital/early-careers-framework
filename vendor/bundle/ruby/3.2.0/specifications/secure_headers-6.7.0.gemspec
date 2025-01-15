# -*- encoding: utf-8 -*-
# stub: secure_headers 6.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "secure_headers".freeze
  s.version = "6.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Neil Matatall".freeze]
  s.date = "2024-08-09"
  s.description = "Add easily configured security headers to responses\n    including content-security-policy, x-frame-options,\n    strict-transport-security, etc.".freeze
  s.email = ["neil.matatall@gmail.com".freeze]
  s.homepage = "https://github.com/twitter/secureheaders".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Manages application of security headers with many safe defaults.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
