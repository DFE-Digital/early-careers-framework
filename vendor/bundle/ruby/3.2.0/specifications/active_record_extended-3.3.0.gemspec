# -*- encoding: utf-8 -*-
# stub: active_record_extended 3.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "active_record_extended".freeze
  s.version = "3.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["George Protacio-Karaszi".freeze, "Dan McClain".freeze, "Olivier El Mekki".freeze]
  s.date = "2024-07-22"
  s.description = "Adds extended functionality to Activerecord Postgres implementation".freeze
  s.email = ["georgekaraszi@gmail.com".freeze, "git@danmcclain.net".freeze, "olivier@el-mekki.com".freeze]
  s.homepage = "https://github.com/georgekaraszi/ActiveRecordExtended".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Adds extended functionality to Activerecord Postgres implementation".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.2", "< 8.0.0"])
  s.add_runtime_dependency(%q<pg>.freeze, ["< 3.0"])
end
