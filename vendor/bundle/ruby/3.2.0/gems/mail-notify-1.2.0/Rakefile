# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"
require "coveralls/rake/task"

Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task default: %i[standard spec coveralls:push]
