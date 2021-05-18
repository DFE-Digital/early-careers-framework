# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme

# Limit directories to watch https://github.com/guard/guard/wiki/Guardfile-DSL---Configuring-Guard#directories
directories(%w[lib spec].select { |d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist") })

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Re-run all specs for any change in application code
  watch(%r{^lib/(.+)\.rb$}) do
    "spec"
  end

  # Re-run features for any change to turnip feature definitions
  watch(%r{^spec/features/(.+)\.feature$})
  watch(%r{^spec/(steps|placeholders)/(.+)\.rb$}) do |m|
    # run specific feature file if changed, else re-run all features
    Dir[File.join("**/#{m[1]}.feature")][0] || "spec/features"
  end
end
