# -*- encoding: utf-8 -*-
# stub: rspec-default_http_header 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-default_http_header".freeze
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kenichi TAKAHASHI".freeze]
  s.date = "2021-10-21"
  s.description = "".freeze
  s.email = ["kenichi.taka@gmail.com".freeze]
  s.homepage = "http://github.com/kenchan/rspec-default_http_header".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Set default http headers in request specs".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rspec-rails>.freeze, ["> 3.0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
