# -*- encoding: utf-8 -*-
# stub: sentry-sidekiq 5.22.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sentry-sidekiq".freeze
  s.version = "5.22.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/getsentry/sentry-ruby/issues", "changelog_uri" => "https://github.com/getsentry/sentry-ruby/blob/5.22.1/CHANGELOG.md", "documentation_uri" => "http://www.rubydoc.info/gems/sentry-sidekiq/5.22.1", "homepage_uri" => "https://github.com/getsentry/sentry-ruby/tree/5.22.1/sentry-sidekiq", "source_code_uri" => "https://github.com/getsentry/sentry-ruby/tree/5.22.1/sentry-sidekiq" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sentry Team".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-12-16"
  s.description = "A gem that provides Sidekiq integration for the Sentry error logger".freeze
  s.email = "accounts@sentry.io".freeze
  s.extra_rdoc_files = ["README.md".freeze, "LICENSE.txt".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "https://github.com/getsentry/sentry-ruby/tree/5.22.1/sentry-sidekiq".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A gem that provides Sidekiq integration for the Sentry error logger".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<sentry-ruby>.freeze, ["~> 5.22.1"])
  s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 3.0"])
end
