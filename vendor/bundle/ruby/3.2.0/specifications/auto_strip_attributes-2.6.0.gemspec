# -*- encoding: utf-8 -*-
# stub: auto_strip_attributes 2.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "auto_strip_attributes".freeze
  s.version = "2.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Olli Huotari".freeze]
  s.date = "2020-03-25"
  s.description = "AutoStripAttributes helps to remove unnecessary whitespaces from ActiveRecord or ActiveModel attributes. It's good for removing accidental spaces from user inputs. It works by adding a before_validation hook to the record. It has option to set empty strings to nil or to remove extra spaces inside the string.".freeze
  s.email = ["olli.huotari@iki.fi".freeze]
  s.homepage = "https://github.com/holli/auto_strip_attributes".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Removes unnecessary whitespaces in attributes. Extension to ActiveRecord or ActiveModel.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.0"])
  s.add_development_dependency(%q<minitest>.freeze, [">= 2.8.1"])
  s.add_development_dependency(%q<mocha>.freeze, ["~> 0.14"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
